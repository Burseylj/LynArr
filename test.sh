echo "make all"
make all
echo ""
echo ""
echo "Executing test..."
echo ""

echo "*****Normal cates"
./lynarr a
./lynarr abc
./lynarr abcdefghijklmnopqrst
echo "*****DONE Normal cases"
echo ""
echo "*****ERROR cases"
./lynarr 
./lynarr abc adf
./lynarr aBcD
./lynarr A
./lynarr a%b0d
./lynarr abcdefghijklmnopqrstu
echo "*****Done with ERROR cases"
echo ""
echo "*****Sample Test cases"
./lynarr aabaabbababb 
./lynarr abcdefgh 
./lynarr abababb 
./lynarr abbababaaaba
echo "*****Done Sample Test cases"

echo "clean up"
make clean
