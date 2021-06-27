if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

scp root@145.100.106.195:/root/epi-bf-* $1
scp root@145.100.106.196:/root/epi-bf-* $1
