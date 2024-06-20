if [ -z "$nCPUs" ]; then
    nCPUs=$(grep -c '^processor' /proc/cpuinfo 2>/dev/null || sysctl -n hw.ncpu)
fi
pref=$(basename $0 .sh)
DIR=../bin
JF="$DIR/jellyfish"
[ -n "$VALGRIND" ] && JF="valgrind $JF"
SRCDIR=/work/alh166/genome_2024/bin/jellyfish-2.3.1
BUILDDIR=/work/alh166/genome_2024/bin/jellyfish-2.3.1

check () {
    cut -d\  -f 2 $1 | xargs md5sum | sed 's/ \*/ /' | sort -k2,2 | diff -w $DIFFFLAGS $1 -
}

ENABLE_RUBY_BINDING=""
RUBY=""
ENABLE_PYTHON_BINDING=""
PYTHON=""
ENABLE_PERL_BINDING=""
PERL=""
SAMTOOLS=""
UNIX2DOS="/usr/bin/unix2dos"

if [ -n "$DEBUG" ]; then
    set -x;
    DIFFFLAGS="-y"
fi

set -e
