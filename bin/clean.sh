rmall () {
    for exc in jpg jpeg jpe png gif torrent; do
        rm *.$exc
    done
}

for d in . Downloads Documents tmp; do
    pushd "$d" && 
    rmall
    popd
done
