#! /usr/bin/bash
set -uvx
set -e
cwd=`pwd`
version=$(pkgver)
comment=$1

rm -rf tmp*

rm -f *.exe
find . -name "*.exe" -exec rm -f {} \;

rm -f *.txt
find . -name "*.txt" -exec rm -f {} \;

echo $version

pubspec "$version"

dart format .

./do-analyze.sh
./do-test.sh

git checkout CHANGELOG.md
diff=`git diff pubspec.yaml | sed "/^[^-+].*/d"`

cat << EOS >> CHANGELOG.md

## $version

- $comment

\`\`\`
$diff
\`\`\`
EOS

#dos2unix pubspec.yaml
#dos2unix CHANGELOG.md

#exit 0

dart pub publish --force

cd $cwd
tag="std-$version"
git add .
git commit -m"std: $comment"
git tag -a "$tag" -m"$tag"
git push origin "$tag"
git push origin HEAD:main
git remote -v
