# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
PS1='\u@\h:\w# '
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
alias ls='ls ${LS_OPTIONS}'
alias ll='ls ${LS_OPTIONS} -l'

# Save history in realtime
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

export EDITOR="/bin/nano"
# export PATH="${PATH}:/opt/shiki"

if [ ! -f "${HOME}/.mountloader" ]; then
  while true; do
    CNT=60
    echo -en "\033[1;36mFinding for bootloader disk .\033[0m"
    while [ ${CNT} -gt 0 ]; do
      LOADER_DISK_PART1="$(lsblk -pno KNAME,LABEL | grep 'SHIKI1' | awk '{print $1}')"
      LOADER_DISK_PART2="$(lsblk -pno KNAME,LABEL | grep 'SHIKI2' | awk '{print $1}')"
      LOADER_DISK_PART3="$(lsblk -pno KNAME,LABEL | grep 'SHIKI3' | awk '{print $1}')"
      [ -n "${LOADER_DISK_PART1}" -a -n "${LOADER_DISK_PART2}" -a -n "${LOADER_DISK_PART3}" ] && break
      echo -en "\033[1;36m.\033[0m"
      CNT=$((${CNT} - 1))
      sleep 1
    done
    echo

    if [ -z "${LOADER_DISK_PART1}" -a -z "${LOADER_DISK_PART2}" -a -z "${LOADER_DISK_PART3}" ]; then
      echo -e "\033[1;31mBootloader disk not found.\033[0m"
      break
    fi
    if [ -z "${LOADER_DISK_PART1}" -o -z "${LOADER_DISK_PART2}" -o -z "${LOADER_DISK_PART3}" ]; then
      echo -e "\033[1;31mBootloader disk seems to be damaged.\033[0m"
      break
    fi
    if [ $(echo "${LOADER_DISK_PART1}" | wc -l) -gt 1 -o $(echo "${LOADER_DISK_PART2}" | wc -l) -gt 1 -o $(echo "${LOADER_DISK_PART3}" | wc -l) -gt 1 ]; then
      echo -e "\033[1;31mMultiple bootloader disks found, please insert only one bootloader disk.\033[0m"
      break
    fi

    LOADER_DISK="$(lsblk -po PKNAME,LABEL | grep 'SHIKI3' | awk '{print $1}')"

    # Check partitions and ignore eshikiors
    fsck.vfat -aw "${LOADER_DISK_PART1}" >/dev/null 2>&1 || true
    fsck.ext2 -p "${LOADER_DISK_PART2}" >/dev/null 2>&1 || true
    fsck.ext4 -p "${LOADER_DISK_PART3}" >/dev/null 2>&1 || true

    # Make folders to mount partitions
    mkdir -p /mnt/p1
    mkdir -p /mnt/p2
    mkdir -p /mnt/p3
    mount ${LOADER_DISK_PART1} /mnt/p1 2>/dev/null || (
      echo -e "\033[1;31mCan't mount ${LOADER_DISK_PART1}.\033[0m"
      break
    )
    mount ${LOADER_DISK_PART2} /mnt/p2 2>/dev/null || (
      echo -e "\033[1;31mCan't mount ${LOADER_DISK_PART2}.\033[0m"
      break
    )
    mount ${LOADER_DISK_PART3} /mnt/p3 2>/dev/null || (
      echo -e "\033[1;31mCan't mount ${LOADER_DISK_PART3}.\033[0m"
      break
    )

    if [ $(lsblk -pno KNAME,TYPE ${LOADER_DISK} 2>/dev/null | grep "part" | wc -l) -eq 3 ]; then
      # Check if partition 3 occupies all free space, resize if needed
      SIZEOFDISK=$(cat /sys/block/${LOADER_DISK/\/dev\//}/size)
      ENDSECTOR=$(($(fdisk -l ${LOADER_DISK} | grep "${LOADER_DISK_PART3}" | awk '{print $3}') + 1))
      if [ ${SIZEOFDISK}0 -ne ${ENDSECTOR}0 ]; then
        echo -e "\033[1;36mResizing ${LOADER_DISK_PART3}\033[0m"
        echo -e "d\n\nn\n\n\n\n\nn\nw" | fdisk "${LOADER_DISK}" >/dev/null 2>&1
        resize2fs "${LOADER_DISK_PART3}"
      fi
    fi

    # Move/link SSH machine keys to/from cache volume
    [ ! -d "/mnt/p3/ssh" ] && cp -R "/etc/ssh" "/mnt/p3/ssh"
    rm -rf "/etc/ssh"
    ln -s "/mnt/p3/ssh" "/etc/ssh"
    # Link bash history to cache volume
    rm -rf ~/.bash_history
    ln -s /mnt/p3/.bash_history ~/.bash_history
    touch ~/.bash_history
    if ! grep -q "menu.sh" ~/.bash_history; then
      echo "menu.sh " >>~/.bash_history
    fi

    echo "export LOADER_DISK=\"${LOADER_DISK}\"" >"${HOME}/.mountloader"
    echo "export LOADER_DISK_PART1=\"${LOADER_DISK_PART1}\"" >>"${HOME}/.mountloader"
    echo "export LOADER_DISK_PART2=\"${LOADER_DISK_PART2}\"" >>"${HOME}/.mountloader"
    echo "export LOADER_DISK_PART3=\"${LOADER_DISK_PART3}\"" >>"${HOME}/.mountloader"

    break
  done
fi

if [ -f "${HOME}/.mountloader" ]; then
  . "${HOME}/.mountloader"

  if [ -d "/opt/shiki" ]; then
    cd "/opt/shiki"
    if [ ! -f "${HOME}/.initialized" ]; then
      touch "${HOME}/.initialized"
      /opt/shiki/init.sh
    fi
    if tty | grep -q "/dev/pts" && [ -z "${SSH_TTY}" ]; then
      /opt/shiki/menu.sh
      #exit  # Allow web access back to shell
    fi
  fi
else
  echo
  lsblk -po KNAME,TRAN,SUBSYSTEMS,LABEL
fi
