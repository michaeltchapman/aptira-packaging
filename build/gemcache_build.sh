#!/usr/bin/env bash

repo=false
nameflag=false
while getopts "h?r:n:" opt; do
    case "$opt" in
    h|\?)
        echo "halp"
        exit 0
        ;; 
    r)  repo=$OPTARG
        ;; 
    n)  name=$OPTARG
        nameflag=true
        ;; 
    esac
done

if ! $nameflag ; then
  echo "Gem name must be specified with -n"
  exit 0
fi

for i in ruby ruby-devel; do
  if ! yum info $i | grep -q installed ; then
    yum install -y $i
  fi
done

hash git 2>/dev/null || {
  yum install -y -q git
}

cwd=`pwd`
mkdir -p $cwd/tmp
mkdir -p $cwd/gemcache/$name
export GEM_HOME=$cwd/tmp/$name/vendor

if [ "$repo" != 'false' ]; then
  rm -rf tmp/$name
  git clone $repo tmp/$name
  mkdir -p $cwd/tmp/$name/vendor

  hash bundle 2>/dev/null || {
    gem install bundler --no-ri --no-rdoc
  }

  cd tmp/$name
  # Build package
  cp `gem build *.gemspec | grep File | sed 's/^[\ ]*File://g'` ../../gemcache/$name

  # Get deps from gem repo
  $cwd/tmp/$name/vendor/bin/bundle install
  cp vendor/cache/* ../../gemcache/$name
else
  mkdir -p tmp/$name/vendor
  gem install $name --no-ri --no-rdoc
  cp tmp/$name/vendor/cache/*.gem gemcache/$name
fi

# Clean
#rm -rf tmp/$name
