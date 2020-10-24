echo "First arg: $1"
echo "Second arg: $2"

mkdir -p ./current_build
cd ./current_build
current_path=$(pwd)

echo $2 | kinit $1
mkdir -p down
cd ./down
downstream_path=$(pwd)
git clone ssh://pkesavap@pkgs.devel.redhat.com/rpms/$3
cd $3
downstream_path=$(pwd)
cd ./..
cd ./..
mkdir -p up
cd ./up
git clone https://github.com/gluster/$4
cd $4
upstream_path=$(pwd)
#cd ./$4

#downstream
cd $(echo $downstream_path |tr -d '\r')
echo "downstream?"
pwd
git checkout $5 #branch
version_from_source="$(cat sources | cut -d' ' -f2- | grep -Eo '[0-9].[0-9].[0-9]-[0-9][0-9]?')"

#current_tag=$(git describe --tags --abbrev=0)
current_tag=$(echo $version_from_source)
choped_no=${current_tag#*-}
sub_ver="$(echo "$((choped_no + 1))" | bc)"
this_tag="$(echo "${current_tag/$choped_no/$sub_ver}")"
echo $this_tag

version_without_v=${this_tag#*v}
version_number=${version_without_v%-*}
choped_no=${current_tag#*-}
sub_ver="$(echo "$((choped_no + 1))" | bc)"

echo $this_tag
echo $version_number

mkdir -p ~/rpmBuild/
cd $upstream_path
git archive $this_tag --format=tar.gz --prefix=$3-$version_number/ -o ~/rpmBuild/$3-$version_without_v.tar.gz

echo "git archive $this_tag --format=tar.gz --prefix=$3-$version_number/ -o ~/rpmBuild/$3-$version_without_v.tar.gz"
echo $downstream_path
cd $downstream_path
echo "old sources"
cat sources
rhpkg new-sources ~/rpmBuild/$3-$version_without_v.tar.gz
echo "new sources"
cat  sources
date_is="$(date +"%a %b %d %Y")"
awk -v date1="$date_is" -v this_tag1="$this_tag" -v desc="$6" '1;/%changelog/{printf "* "; printf date1; printf " Prajith Kesava Prasad <pkesavap@redhat.com> "; printf this_tag1; print " "; printf "- "; printf desc; print "\n"; }' $3.spec  > testfile.tmp && mv testfile.tmp $3.spec

git status
git add .
git commit -m  "$7" -s
pwd
#git push 
#rhpkg build --scratch

#rm -rf ~/rpmBuild/

#rm -rf $downstream_path
#rm -rf $upstream_path
#rm -rf $current_path
