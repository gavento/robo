I=turnU-single.png
SIZE=68x68
O=turnU.png

function rotate { # in angle size out
  convert -background transparent $1 -rotate $2 -gravity center -extent $3 $4
}

ROTS=

for a in `seq 0 10 359`; do
  OR=tmp-rot-$a-$I
  rotate $I $a $SIZE $OR
  ROTS="$ROTS $OR"
done
echo $ROTS

montage -background transparent \
  $ROTS \
  -geometry $SIZE+0+0 -tile x4 $O

rm $ROTS
