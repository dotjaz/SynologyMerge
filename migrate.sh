#!/bin/bash
set -e
Dir(){
 if [ ! -d /$TARGET/\@appstore ]; then
   mkdir -p /$TARGET/\@appstore
 fi
}
Help(){
	printf '\n%s\n\t%s' '-s' 'Source (source) volume, should be in the form of volumeX'
	printf '\n%s\n\t%s' '-t' 'Destination (target) volume, should be in the form of volumeX'
	printf '\n%s\n\t%s' '-a' 'If specified, will migrate all packages in current directory (Warning: careful!)\n'
	exit 1
}
All(){
Dir
for f in /$SOURCE/\@appstore/*
do
	pkg="${f##*/}"
	echo $pkg
	[ -e /var/packages/$pkg/scripts/start-stop-status ] && /var/packages/$pkg/scripts/start-stop-status stop &
	sleep 5
	[ -e /var/packages/$pkg/target ] && rm -rf /var/packages/$pkg/target
	[ -e /var/packages/$pkg/etc ] && rm -rf /var/packages/$pkg/etc
	[ -e /var/packages/$pkg/home ] && rm -rf /var/packages/$pkg/home
	[ -e /var/packages/$pkg/tmp ] && rm -rf /var/packages/$pkg/tmp
	[ -e /var/packages/$pkg/var ] && rm -rf /var/packages/$pkg/var
	[ -e /$SOURCE/\@appstore/$pkg ] && mv /$SOURCE/\@appstore/$pkg /$TARGET/\@appstore && ln -s /$TARGET/\@appstore/$pkg /var/packages/$pkg/target
	[ -e /$SOURCE/\@appconf/$pkg ] && mv /$SOURCE/\@appconf/$pkg /$TARGET/\@appconf && ln -s /$TARGET/\@appconf/$pkg /var/packages/$pkg/etc
	[ -e /$SOURCE/\@apphome/$pkg ] && mv /$SOURCE/\@apphome/$pkg /$TARGET/\@apphome && ln -s /$TARGET/\@apphome/$pkg /var/packages/$pkg/home
	[ -e /$SOURCE/\@apptemp/$pkg ] && mv /$SOURCE/\@apptemp/$pkg /$TARGET/\@apptemp && ln -s /$TARGET/\@apptemp/$pkg /var/packages/$pkg/tmp
	[ -e /$SOURCE/\@appdata/$pkg ] && mv /$SOURCE/\@appdata/$pkg /$TARGET/\@appdata && ln -s /$TARGET/\@appdata/$pkg /var/packages/$pkg/var
done
	mv /$SOURCE/\@appstore/* /$TARGET/\@appstore
	mv /$SOURCE/\@appconf/* /$TARGET/\@appconf
	mv /$SOURCE/\@apphome/* /$TARGET/\@apphome
	mv /$SOURCE/\@apptemp/* /$TARGET/\@apptemp
	mv /$SOURCE/\@appdata/* /$TARGET/\@appdata

for f in /$TARGET/\@appstore/*
do
	pkg="${f##*/}"
	echo $pkg
	[ -e /$TARGET/\@appstore/$pkg ] && ln -sf /$TARGET/\@appstore/$pkg /var/packages/$pkg/target
	[ -e /$TARGET/\@appconf/$pkg ] && ln -sf /$TARGET/\@appconf/$pkg /var/packages/$pkg/etc
	[ -e /$TARGET/\@apphome/$pkg ] && ln -sf /$TARGET/\@apphome/$pkg /var/packages/$pkg/home
	[ -e /$TARGET/\@apptemp/$pkg ] && ln -sf /$TARGET/\@apptemp/$pkg /var/packages/$pkg/tmp
	[ -e /$TARGET/\@appdata/$pkg ] && ln -sf /$TARGET/\@appdata/$pkg /var/packages/$pkg/var
done
exit 1
}

Run(){
Dir
for f in /$SOURCE/\@appstore/*
do
	pkg="${f##*/}"
	echo $pkg
	read -p "proceed?(y/n) " pcd
	if [ "$pcd" == "y" ]; then
		[ -e /var/packages/$pkg/scripts/start-stop-status ] && /var/packages/$pkg/scripts/start-stop-status stop &
		sleep 5
		[ -e /var/packages/$pkg/target ] && rm -rf /var/packages/$pkg/target
		[ -e /var/packages/$pkg/etc ] && rm -rf /var/packages/$pkg/etc
		[ -e /var/packages/$pkg/home ] && rm -rf /var/packages/$pkg/home
		[ -e /var/packages/$pkg/tmp ] && rm -rf /var/packages/$pkg/tmp
		[ -e /var/packages/$pkg/var ] && rm -rf /var/packages/$pkg/var
		[ -e /$SOURCE/\@appstore/$pkg ] && mv /$SOURCE/\@appstore/$pkg /$TARGET/\@appstore && ln -s /$TARGET/\@appstore/$pkg /var/packages/$pkg/target
		[ -e /$SOURCE/\@appconf/$pkg ] && mv /$SOURCE/\@appconf/$pkg /$TARGET/\@appconf && ln -s /$TARGET/\@appconf/$pkg /var/packages/$pkg/etc
		[ -e /$SOURCE/\@apphome/$pkg ] && mv /$SOURCE/\@apphome/$pkg /$TARGET/\@apphome && ln -s /$TARGET/\@apphome/$pkg /var/packages/$pkg/home
		[ -e /$SOURCE/\@apptemp/$pkg ] && mv /$SOURCE/\@apptemp/$pkg /$TARGET/\@apptemp && ln -s /$TARGET/\@apptemp/$pkg /var/packages/$pkg/tmp
		[ -e /$SOURCE/\@appdata/$pkg ] && mv /$SOURCE/\@appdata/$pkg /$TARGET/\@appdata && ln -s /$TARGET/\@appdata/$pkg /var/packages/$pkg/var
		ls -l /var/packages/$pkg
		[ -e /var/packages/$pkg/scripts/start-stop-status ] && /var/packages/$pkg/scripts/start-stop-status start &
	fi
done
}

Start(){
Dir
for f in /$TARGET/\@appstore/*
do
	pkg="${f##*/}"
	echo $pkg
	read -p "proceed?(y/n) " pcd
	if [ "$pcd" == "y" ]; then
		[ -e /var/packages/$pkg/scripts/start-stop-status ] && /var/packages/$pkg/scripts/start-stop-status start &
		sleep 5
	fi
done
}

SOURCE='NONE'
TARGET='NONE'

opts=":s:t:ah"
while getopts $opts option
do
	case ${option} in
		s) SOURCE=${OPTARG};;
		t) TARGET=${OPTARG};;
		h)
			Help
			;;
		a) ALLPKG=1;;
		\? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
		:  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
		*  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
	esac
done

if [[ $SOURCE != 'NONE' ]] && [[ $TARGET != 'NONE' ]] && [[ $ALLPKG = 1 ]]; then
	All
	Start
else if [[ $SOURCE != 'NONE' ]] && [[ $TARGET != 'NONE' ]]; then
	Run
	Start
else
	Help
fi; fi
