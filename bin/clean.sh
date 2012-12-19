rmall () {
    for exc in jpg jpeg jpe png gif torrent; do
        rm *.$exc > /dev/null
    done
}

pushd ~
for d in . Downloads Documents tmp; do
    pushd "$d" && 
    rmall
    popd
done
popd
