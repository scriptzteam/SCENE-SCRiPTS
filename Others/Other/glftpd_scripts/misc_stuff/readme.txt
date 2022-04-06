banned

Eggdrop script for banning IPs in iptables

    Place the banned folder under /scripts
    Load the scripts/banned/banned.tcl in your eggdrop.conf.
    Edit channels variable at top of banned.tcl to specify channels where commands can be run.
    Ensure that user the eggdrop is run as has sudo access to run /scripts/iptables.sh no password prompt.
