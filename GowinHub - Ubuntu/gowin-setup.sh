#!/bin/bash
echo "Initiating Gowin Setup.."

#---------------------------------------------------
#Sytem checks and initializing regex expressions
#---------------------------------------------------
ARCH="$(uname -m)"
OS="$(uname -s)"
REGEX64='(\.linux-amd64\.tar.gz)$'
REGEX32='(\.linux-386\.tar.gz)$'

#---------------------------------------------------
#Golang Package Details - DIrectory/Package Version
#---------------------------------------------------
GOLANG_LATEST_PACK="go1.16.4.linux-amd64.tar.gz"
GOLANG_PACKAGE_DIR="golang.org/dl/"
GOLANG_PACKAGE=${GOLANG_PACKAGE_DIR}${GOLANG_LATEST_PACK}

#----------------------------------------------------------
#Checkinf compatibility for Golang package installation
#System64 and System32 Architecture Comptability checks
#----------------------------------------------------------
system_check() {
    if
        ([ ${ARCH} == "x86_64" ] &&
            [ ${OS} == "Linux" ])
    then
        if [[ $GOLANG_LATEST_PACK =~ $REGEX64 ]]; then
            echo "System Architecture -  $ARCH. GoLang Package - $GOLANG_LATEST_PACK compatible with system.."
            return 1
        else
            echo "System Architecture -  $ARCH. GoLang Package - $GOLANG_LATEST_PACK not compatible with system.."
            exit 1
        fi
    fi
    if
        ([ ${ARCH} == "x86" ] &&
            [ ${OS} == "Linux" ])
    then
        if [[ $GOLANG_LATEST_PACK -eq $REGEX32 ]]; then
            echo "System Architecture -  $ARCH. GoLang Package - $GOLANG_LATEST_PACK compatible with system.."
            return 1
        else
            echo "System Architecture -  $ARCH. GoLang Package - $GOLANG_LATEST_PACK not compatible with system.."
            exit 1
        fi
    fi
}

#Fetching Golang Tar and unpacking
#Archive Package update
#sudo apt autoremove && sudo apt-get update -y
system_check
if [[ $? -eq 1 ]]; then
    wget -cpv "https://golang.org/dl/$GOLANG_LATEST_PACK" --tries=5 --progress=bar
    if [[ -f "${GOLANG_PACKAGE}" ]]; then
        echo "Verifying package integrity with SHA256 Checksum File.."
        shasum -a 256 $GOLANG_PACKAGE
        if [[ -d "/usr/local/go" ]]; then
            while true; do
                read -p "Already existing dir at /usr/local/go. Do you want to remove and reinstall? (Y/n)" yn
                case $yn in
                [Yy]*)
                    sudo rm -rf "/usr/local/go" && echo -n "Removing existing dir /usr/local/go.."
                    echo "  Completed"
                    break
                    ;;
                [Nn]*)
                    echo "Exiting.."
                    exit 39
                    ;;
                *) echo "Invalid Option.." ;;
                esac
            done
        fi
        echo -n "Unpackaging GoLang tar.gz file.."
        sudo tar -xzf $GOLANG_PACKAGE -C "/usr/local"
        if [[ $? -eq 1 ]]; then
            echo " Completed"
            echo "Setting up environment variables in .bashrc file"
            echo "export  PATH=$PATH:/usr/local/go/bin" >>.bashrc
            echo "export GOPATH=/usr/local/go" >>.bashrc
            source .bashrc
            echo "GoLang Setup has been completed successfully!"
        else
            echo "Failed to extract. Error exit code - $?"
            exit 1
        fi
    else
        echo "${GOLANG_PACKAGE_DIR}${GOLANG_LATEST_PACK} doesn't exist. Please retry"
    fi
fi
