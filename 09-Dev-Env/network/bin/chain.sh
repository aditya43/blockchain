#!/bin/bash
# Carries out desired chaincode operations
# Make sure that the environment variables are set before invoking this script
function usage {
    # echo    'Usage: chain.sh  install | instantiate | query | invoke | list | upgrade | install-auto | upgrade-auto'
    echo    'Usage: chain.sh  COMMAND  [FLAGS]'
    echo    '       Commands: package | install | queryinstalled or list '
    echo    '                 approveformyorg or approve | checkcommitreadiness or check '
    echo    '                 commit | querycommitted or list'
    echo    '                 instantiate | init | query | invoke'
    echo    '                 help Shows the help'
    echo    '       Flags     -h   Shows the help'
    echo    '                 -o   Shows the command but do NOT execute'
    echo    '                 -p   Applicable for "install" only; creates the package before install'
    # echo    '                 -n   Applicable for "instantiate" & "checkcommitreadiness"; do not set "--init-required"'
}

if [ "$FABRIC_CFG_PATH" == "" ]; then 
   echo "This script requires the Environment to be setup!!! Use one of the following:"
   echo "> source  set-env.sh  acme"
   echo "> source  set-env.sh  budget"
   exit
fi

DIR="$( which set-chain-env.sh)"
DIR="$(dirname $DIR)"

# Read the current setup
source   $DIR/cc.env.sh


# --init-required   This is picked from chaincode props set by set-chain-env.sh
# overriden by the flag -n
INIT_REQUIRED=$CC2_INIT_REQUIRED
IS_INIT=$CC2_INIT_REQUIRED

# Convert shorthand to full command
OPERATION=$1
case $OPERATION in
    "check")
        OPERATION="checkcommitreadiness"
        ;;
    "approve")
        OPERATION="approveformyorg"
        ;;
    "help")
        usage
        exit 0
esac
# Constant that drives if the command is shown on console
SHOW_CMD="show"

# Options | Flags are starting at $2
OPTIND=$((OPTIND+1))

while getopts "npohj" OPTION; do
    case $OPTION in 
        p)  ## Applicable only for install
            if [ "$OPERATION" != "install" ]; then
                echo "ERROR: Option -p may be used only with 'install'"
                exit 0
            fi
            # Set the operation to pinstall that takes care of packaging & installing
            OPERATION="pinstall"
            ;;
        o)  ## Forces to just show the command and NOT execute
            SHOW_CMD="cmd"
            ;;

        n)  ## Applicable only for instantiate
            if [ "$OPERATION" != "instantiate" ] && [ "$OPERATION" != "checkcommitreadiness" ] && [ "$OPERATION" != "approveformyorg" ]; then
                echo "ERROR: Option -n may be used only with 'instantiate' | 'checkcommitreadiness' | 'approveformyorg'  | 'upgrade-auto' "
                exit 0
            fi
            CC2_INIT_REQUIRED="false"
            ;;

        j) # Sets the output format to JSON
           # Applies only to show command
            OUTPUT_FORMAT=" -O json "
            ;;
        h)  # Show the usage
            usage
            exit 0
            ;;
        
    esac
done

# This is driven by the -n flag
# If -n is NOT used then its driven by the props set by set-chain-env.sh
# if [ "$CC2_INIT_REQUIRED" == "true" ]; then
#     INIT_REQUIRED="--init-required"
#     IS_INIT="--isInit"
# else 
#     INIT_REQUIRED=""
#     IS_INIT=""
# fi

# # --signature-policy 
# SIG_POLICY=""
# if [ "$CC2_SIGNATURE_POLICY" != "" ]; then
#     SIG_POLICY="--signature-policy \"$CC2_SIGNATURE_POLICY\""
# fi
# # --channel-config-policy
# CHANNEL_CONFIG_POLICY=""
# if [ "$CC2_CHANNEL_CONFIG_POLICY" != "" ]; then
#     CHANNEL_CONFIG_POLICY="--channel-config-policy \"$CC2_CHANNEL_CONFIG_POLICY\""
# fi
# # --collections-config
# PRIVATE_DATA_JSON=""
# if [ "$CC_PRIVATE_DATA_JSON" != "" ]; then
#     PRIVATE_DATA_JSON="--collections-config $GOPATH/src/$CC_PATH/$CC_PRIVATE_DATA_JSON"
# fi

# update the package-id
# get-package-id.sh -n $CC_NAME -v $CC_VERSION
# source $CC2_ENV_FOLDER/get-package-id

get-cc-installed.sh &> /dev/null
source $CC2_ENV_FOLDER/get-cc-installed &> /dev/null

# Echos the command if requested
function show_command_execute {
    if [ "$SHOW_CMD" == "show" ]; then
        echo $cmd
        echo
        eval $cmd
        return
    elif [ "$SHOW_CMD" == "cmd" ]; then
        echo $cmd
        echo
    else 
        eval $cmd
    fi
}


# Ensure that endorsing peer address is set
function update_properties {
    get-cc-info.sh &> /dev/null
    source $CC2_ENV_FOLDER/get-cc-info &> /dev/null

    # Update the endorsing peers
    case  "$CC2_ENDORSING_PEERS" in
        "auto")
            CC2_ENDORSING_PEERS="--peerAddresses=$CORE_PEER_ADDRESS"
            ;;
        "acme")
            CC2_ENDORSING_PEERS="--peerAddresses=acme-peer1.acme.com:7051"
            ;;
        "budget")
            CC2_ENDORSING_PEERS="--peerAddresses=budget-peer1.budget.com:8051"
            ;;
        "both")
            CC2_ENDORSING_PEERS="--peerAddresses=acme-peer1.acme.com:7051 --peerAddresses=budget-peer1.budget.com:8051"
            ;;
        *)
            CC2_ENDORSING_PEERS="--peerAddresses=$CORE_PEER_ADDRESS"
    esac
    # Update local variable for initialization
    if [ "$CC2_INIT_REQUIRED" == "true" ]; then
        INIT_REQUIRED="--init-required"
        IS_INIT="--isInit"
    else 
        INIT_REQUIRED=""
        IS_INIT=""
    fi
    # --signature-policy 
    SIG_POLICY=""
    if [ "$CC2_SIGNATURE_POLICY" != "" ]; then
        SIG_POLICY="--signature-policy \"$CC2_SIGNATURE_POLICY\""
    fi
    # --channel-config-policy
    CHANNEL_CONFIG_POLICY=""
    if [ "$CC2_CHANNEL_CONFIG_POLICY" != "" ]; then
        CHANNEL_CONFIG_POLICY="--channel-config-policy \"$CC2_CHANNEL_CONFIG_POLICY\""
    fi
    # --collections-config
    PRIVATE_DATA_JSON=""
    if [ "$CC_PRIVATE_DATA_JSON" != "" ]; then
        PRIVATE_DATA_JSON="--collections-config $GOPATH/src/$CC_PATH/$CC_PRIVATE_DATA_JSON"
    fi
}

# Init once
update_properties

# Package
function cc_package {

    # Checks the current installed version
    # Increments the max version

    # If chaincode has never been installed
    if [ "$INSTALLED_MAX_LABEL_INTERNAL_VERSION" == "-1" ]; then 
        INTERNAL_DEV_VERSION=1
    else
        # Increment the internal version
        # set-chain-env.sh -x
        # source   $DIR/cc.env.sh 
        INTERNAL_DEV_VERSION=$((INSTALLED_MAX_LABEL_INTERNAL_VERSION+1))
    fi

    # if [ "$INSTALLED_MAX_LABEL_INTERNAL_VERSION" != "-1" ] && [ "$SHOW_CMD" != "cmd" ]; then

    #     # Simply increment the internal version
    #     set-chain-env.sh -x
    #     source   $DIR/cc.env.sh 
    # else 
    #    # Don't update the internal
    #    INTERNAL_DEV_VERSION=$((INTERNAL_DEV_VERSION+1))
    # fi
 
    mkdir -p  $CC2_PACKAGE_FOLDER
    echo "==>Creating package: $CC2_PACKAGE_FOLDER/$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION.tar.gz"
    cmd="peer lifecycle chaincode package $CC2_PACKAGE_FOLDER/$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION.tar.gz -p $CC_PATH \
                --label="$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION" -l $CC_LANGUAGE"
    show_command_execute $cmd
}

# Install
function cc_install {

    # If chaincode has never been installed
    if [ "$INSTALLED_MAX_LABEL_INTERNAL_VERSION" == "-1" ]; then 
        INTERNAL_DEV_VERSION=1
    else
        # Increment the internal version
        # set-chain-env.sh -x
        # source   $DIR/cc.env.sh 
        INTERNAL_DEV_VERSION=$((INSTALLED_MAX_LABEL_INTERNAL_VERSION+1))
    fi

    # 2.0 Change
    echo "==>Installing chaincode [$CC2_PACKAGE_FOLDER/$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION.tar.gz ---ON--- $CORE_PEER_ADDRESS]"
    # peer chaincode install -l "$CC_LANGUAGE" -n "$CC_NAME" -p "$CC_PATH" -v "$CC_VERSION"
    cmd="peer lifecycle chaincode install  $CC2_PACKAGE_FOLDER/$CC_NAME.$CC_VERSION-$INTERNAL_DEV_VERSION.tar.gz"

    show_command_execute $cmd
}

# Approveformyorg
function cc_approveformyorg {
    # get-cc-info.sh &> /dev/null
    # source $CC2_ENV_FOLDER/get-cc-info &> /dev/null
    update_properties


    # check if package is installed
    if [ "$INSTALLED_MAX_PACKAGE_ID" == "" ] ; then 
        if [ "$SHOW_CMD" != "cmd" ]; then
            echo "Package ID is '' - did you install the chain code with version=$CC_VERSION? check with chain.sh list"
            read -p 'Would you like to approve without install? (y/n) ? ' USER_RESPONSE
            if [ "$USER_RESPONSE" != "y" ]; then
                exit
            fi
        else
            echo "Package ID is '' as chain code $CC_NAME.$CC_VERSION Not Installed"
        fi
    fi

    # Check if org has already approved
    APPROVAL_PENDING=true
    case "$ORGANIZATION_CONTEXT" in
        acme) 
              APPROVAL_DONE=$COMMITTED_APPROVAL_ACME
              ;;
        budget) 
              APPROVAL_DONE=$COMMITTED_APPROVAL_BUDGET
              ;;
    esac

    # Check the committed sequence
    if [ "$COMMITTED_CC_SEQUENCE" != -1 ]; then 
        CC2_SEQUENCE_NEW=$((COMMITTED_CC_SEQUENCE+1))
    else 
        CC2_SEQUENCE_NEW="1"
    fi

    # Inform user if there is a mismatch between seq set in chain-env and committed
    if [ "$APPROVAL_DONE" == "true" ] && [ "$CC2_SEQUENCE" != "$CC2_SEQUENCE_NEW" ]; then
        echo "Specified Sequence different from actual $CC2_SEQUENCE != $CC2_SEQUENCE_NEW "
        read -p  "Would you like to  proceed? (y/n) " USER_RESPONSE
        if [ "$USER_RESPONSE" != "y" ]; then
            exit
        fi
        # set-chain-env.sh -s $CC2_SEQUENCE_NEW
        # CC2_SEQUENCE=$CC2_SEQUENCE_NEW
    fi

    echo "==>Approving for $ORGANIZATION_CONTEXT : [Seq#$CC2_SEQUENCE   $INIT_REQUIRED ]"
    cmd="peer lifecycle chaincode approveformyorg --channelID $CC_CHANNEL_ID  --name $CC_NAME \
         --version $CC_VERSION --package-id $INSTALLED_MAX_PACKAGE_ID --sequence $CC2_SEQUENCE \
         $INIT_REQUIRED  $PRIVATE_DATA_JSON  -o $ORDERER_ADDRESS $SIG_POLICY $CHANNEL_CONFIG_POLICY \
         $CC2_ENDORSING_PEERS --waitForEvent"

    show_command_execute $cmd

}

# Commit
function cc_commit {
    echo "==>Committing for $ORGANIZATION_CONTEXT : [$CC_CHANNEL_ID $CC_NAME.$CC_VERSION  Seq#$CC2_SEQUENCE   $INIT_REQUIRED on $CC2_ENDORSING_PEERS]"
    cmd="peer lifecycle chaincode commit -C $CC_CHANNEL_ID -n $CC_NAME -v $CC_VERSION \
         --sequence $CC2_SEQUENCE  $INIT_REQUIRED    $PRIVATE_DATA_JSON  \
            $SIG_POLICY $CHANNEL_CONFIG_POLICY $CC2_ENDORSING_PEERS --waitForEvent"
        # --peerAddresses=budget-peer1.budget.com:8051  --peerAddresses=acme-peer1.acme.com:7051"

    show_command_execute $cmd
}

# Init
function cc_init {
    # invoke with --isInit
    echo "==>Initializing  -C $CC_CHANNEL_ID -n $CC_NAME"
    cmd="peer chaincode invoke  -C $CC_CHANNEL_ID -n $CC_NAME -c '$CC_CONSTRUCTOR' \
    --waitForEvent $IS_INIT -o $ORDERER_ADDRESS \
    $CC2_ENDORSING_PEERS"
    # --peerAddresses=budget-peer1.budget.com:8051  --peerAddresses=acme-peer1.acme.com:7051"

    show_command_execute $cmd
}

function cc_invoke {
    # invoke
    cmd="peer chaincode invoke -C $CC_CHANNEL_ID -n $CC_NAME  -c '$CC_INVOKE_ARGS' -o $ORDERER_ADDRESS \
     --waitForEvent \
     $CC2_ENDORSING_PEERS"
    #  --peerAddresses=budget-peer1.budget.com:8051  --peerAddresses=acme-peer1.acme.com:7051"

     show_command_execute $cmd
}

# List
function cc_list {
    echo "Chaincode Installed on: [$CORE_PEER_ADDRESS]"
    echo "============================================"
    cmd="peer lifecycle chaincode queryinstalled"
    show_command_execute $cmd

    echo ""
    echo "==========================================="
    cmd="peer lifecycle chaincode querycommitted -C $CC_CHANNEL_ID -n $CC_NAME "

    show_command_execute $cmd
}

# Install auto
# What does this do?
# 1. Get the information on the current install
# 2. 
function cc_install_auto {

    echo "NOT supported in 2.0 and above!!   use  > chain.sh install -p"
    exit

    # 1. Get the latest version of the installed chaincode
    # get-cc-installed.sh
    # source $CC2_ENV_FOLDER/get-cc-installed &> /dev/null

    # 2. Set the New version
    # echo $CC_NAME
    # echo $INSTALLED_MAX_LABEL_VERSION
    if [ "$INSTALLED_MAX_LABEL_VERSION" == "-1" ]; then 
        $INSTALLED_MAX_LABEL_VERSION_NEW="1.0"
    else 
        INSTALLED_MAX_LABEL_VERSION_NEW=${INSTALLED_MAX_LABEL_VERSION%.*}
        INSTALLED_MAX_LABEL_VERSION_NEW=$((INSTALLED_MAX_LABEL_VERSION_NEW+1))
    fi
    INSTALLED_MAX_LABEL_VERSION_NEW="$INSTALLED_MAX_LABEL_VERSION_NEW".0
    # echo $INSTALLED_MAX_LABEL_VERSION_NEW

    
    # Update the chain environment
    set-chain-env.sh -v $INSTALLED_MAX_LABEL_VERSION_NEW
    # Update the current setup
    source   $DIR/cc.env.sh

    echo "Chaincode Packaging & Installation: [$CC_NAME $CC_VERSION]"
    echo "============================================="

    cc_pinstall

}

# Auto upgrade
function cc_upgrade_auto {
    # 1. auto-install
    # cc_install_auto
    cc_pinstall
    
    # 2. Check the latest committed sequence
    get-cc-info.sh  &> /dev/null
    source $CC2_ENV_FOLDER/get-cc-info &> /dev/null

    # 3. Increment the sequence number
    if [ "$COMMITTED_CC_SEQUENCE" == "-1" ]; then
      COMMITTED_CC_SEQUENCE=1
    else
      COMMITTED_CC_SEQUENCE=$((COMMITTED_CC_SEQUENCE+1))
    fi
    # echo $COMMITTED_CC_SEQUENCE

    # 5. Set the sequence number only if the update is REAL
    if [ "$SHOW_CMD" != "cmd" ]; then
        set-chain-env.sh -s $COMMITTED_CC_SEQUENCE
        source   $DIR/cc.env.sh
    fi
    # 4. Instantiate
    cc_instantiate
}

# instantiate
function cc_instantiate {
    # approve
    cc_approveformyorg
    # commit
    cc_commit
    # init
    if [ $CC2_INIT_REQUIRED == "true" ]; then
        cc_init
    fi
}

# package+install
function cc_pinstall {
    cc_package

    cc_install
}


if [ -z $OPERATION ];
then
    usage
elif  [ "$OPERATION" == "list" ]; then
    # List
    cc_list

elif  [ "$OPERATION" == "upgrade-auto" ]; then
    cc_upgrade_auto
elif  [ "$OPERATION" == "package" ]; then
    # Package
    cc_package

elif  [ "$OPERATION" == "install" ]
then
    cc_install

elif [ "$OPERATION" == "install-auto" ]; then

    cc_install_auto

elif  [ "$OPERATION" == "queryinstalled" ]
then
    echo "Installed on: [$CORE_PEER_ADDRESS]"
    cmd="peer lifecycle chaincode queryinstalled"

    show_command_execute $cmd

elif  [ "$OPERATION" == "approveformyorg" ]; then
    # Approveformyorg
    
    cc_approveformyorg

elif  [ "$OPERATION" == "checkcommitreadiness" ]; then
# Checkcommitreadiness
    cmd="peer lifecycle chaincode checkcommitreadiness -C $CC_CHANNEL_ID -n \
    $CC_NAME --sequence $CC2_SEQUENCE -v $CC_VERSION  $INIT_REQUIRED $SIG_POLICY  \
    $PRIVATE_DATA_JSON  "
    show_command_execute $cmd

elif  [ "$OPERATION" == "commit" ]; then
# Commit

    cc_commit

    
elif  [ "$OPERATION" == "querycommitted" ]; then
# Querycommitted
    cmd="peer lifecycle chaincode querycommitted $OUTPUT_FORMAT -C $CC_CHANNEL_ID -n $CC_NAME "

    show_command_execute $cmd

elif  [ "$OPERATION" == "init" ]; then
    cc_init

elif  [ "$OPERATION" == "query" ]; then
# query
    cmd="peer chaincode query -C $CC_CHANNEL_ID -n $CC_NAME -c '$CC_QUERY_ARGS' "

    show_command_execute $cmd

elif  [ "$OPERATION" == "invoke" ]; then
    cc_invoke
elif  [ "$OPERATION" == "instantiate" ]; then
    
    cc_instantiate

elif [ "$OPERATION" == "pinstall" ]; then
    cc_pinstall
else
    usage
    echo "Invalid operation!!!"
fi