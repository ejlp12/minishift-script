#! /bin/bash
# https://raw.githubusercontent.com/ahilbig/docker-machine-ipconfig/master/minishift-ipconfig

# Manage IP address settings on your minishifts
#
#  ls                             List running minishifts' ip addresses
#
#  static <machine> [ip-address]  Configure <machine> to use a static IP address
#                                 (default is current address)
#
#  dhcp <machine>                 Configure <machine> to use DHCP client to gather IP address
#
#  hosts                          Update /etc/hosts file

set -e
operation=${1}
shift

case $(uname) in
    CYGWIN*)
        sudo ()
        {
            if [[ $# -eq 0 ]]; then
                printf "Usage: sudo program arg1 arg2 ...\n";
                return 1;
            fi;
            prog="$1";
            shift;
            cygstart --action=runas $(which "$prog") "$@"
        }
        ;;
esac

case $operation in
    # Get our currently in-use minishift addresses
    ls)
        printf "%-8s %s\n" "State" "IP Address"
        printf "%s\n" "------------------------------------------------"
            ip=$(minishift ip)
            bootsync="/var/lib/boot2docker/bootsync.sh"
            state=$(minishift ssh "
                if [[ -f $bootsync ]] && grep -q \"# IP=$ip\" $bootsync; then
                    echo static;
                else
                    echo dhcp;
                fi
            ")
            printf "%-8s %s\n" $state $ip
        ;;

    # Configure the minishift to use a static ip address (defaults to current address)
    static)
        # Get the machine's ip and broadcast addresses (or use the ip address provided on the command-line)
        ip=${1:-$(minishift ip)}
        broadcast=${ip%.*}.255

        # Create the bootsync.sh file
cat <<EOF | minishift ssh "sudo tee /var/lib/boot2docker/bootsync.sh >/dev/null"
#!/bin/sh
# This file was automatically generated by running "$(basename $BASH_SOURCE)" from the minishift host
# IP=$ip

# Stop the DHCP service for our host-only inteface
[[ -f /var/run/udhcpc.eth1.pid ]] && kill \$(cat /var/run/udhcpc.eth1.pid) 2>/dev/null || :

# Configure the interface to use the assigned IP address as a static address
ifconfig eth1 $ip netmask 255.255.255.0 broadcast $broadcast up
EOF

        # Set the bootsync.sh file as executable
        minishift ssh "sudo chmod u+x /var/lib/boot2docker/bootsync.sh"

        # Go ahead and run the script to switch to static ip mode
        minishift ssh "sudo /var/lib/boot2docker/bootsync.sh"

        # Regenerate the minishift certs
        # TODO Add something if needed minishift regenerate-certs

        # Status report
        minishift ssh "ip addr show eth1 | grep 'inet.*eth1'"
        printf "minishift now has a static ip address\n" 
        ;;

    # Configure the minishift to use a DHPC address
    dhcp)
        # Delete the config file and bring the interface down
        minishift ssh "sudo rm -f /var/lib/boot2docker/bootsync.sh"
        minishift ssh "sudo ifconfig eth1 down"

        # Start up the DHPC client again
        minishift ssh "sudo /sbin/udhcpc -b -i eth1 -x hostname boot2docker -p /var/run/udhcpc.eth1.pid &"

        # Status report
        printf "minishift now has a dynamic ip address\n" 
        ;;

    # Update the hosts file to match the current minishift addresses
    hosts)
        tmp_etc_hosts=$(mktemp /tmp/etc_hosts.XXXXXX)
        trap "rm -f $tmp_etc_hosts $tmp_etc_hosts.bak" EXIT

        # Copy the /etc/hosts file contents to somewhere we can work with them
        cp /etc/hosts $tmp_etc_hosts || :

        # Update the file contents with the current state of the minishift IP addresses
        ip=$(minishift ip)

        sed -i.bak -e "/ minishift/d" $tmp_etc_hosts
            printf "%-20s %s\n" $ip >> $tmp_etc_hosts

        # Fix line endings
        case $(uname) in
            CYGWIN*) unix2dos $tmp_etc_hosts &>/dev/null ;;
        esac

        # Only attempt to update the /etc/hosts file if changes need to be made
        if ! diff -q /etc/hosts $tmp_etc_hosts &>/dev/null; then
            # Do not use mv here. Cygwin users depend on this being a cp operation
            sudo cp $tmp_etc_hosts /etc/hosts
            case $(uname) in
                CYGWIN*) sleep 1 ;;  # Need to wait for async sudo operation to complete
            esac
        fi

        # Display the current/updated /etc/hosts file
        printf "\n"
        printf "# /etc/hosts\n"
        printf "%s\n" "--------------------------------"
        sed -Ee '/^[[:space:]]*(#|$)/d' /etc/hosts
        ;;

    *)
        printf "Usage: $(basename $BASH_SOURCE) <command> args...\n"
        printf "\n"
        printf "Commands:\n"
        printf "    ls                             List running minishifts' ip addresses\n"
        printf "\n"
        printf "    static <machine> [ip-address]  Configure <machine> to use a static IP address\n"
        printf "                                   (default is current address)\n"
        printf "\n"
        printf "    dhcp <machine>                 Configure <machine> to use DHCP client to gather IP address\n"
        printf "\n"
        printf "    hosts                          Update /etc/hosts file\n"
    ;;
esac
