setMode -bs
setMode -bs
setCable -port auto
Identify 
identifyMPM 
assignFile -p 2 -file "/afs/athena.mit.edu/user/a/d/adhikara/Documents/6.111things/6.111 project/bobateam/flash_flash_flash/lab5.bit"
Program -p 2 
setMode -bs
deleteDevice -position 1
deleteDevice -position 1
deleteDevice -position 1
setMode -ss
setMode -sm
setMode -hw140
setMode -spi
setMode -acecf
setMode -acempm
setMode -pff
setMode -bs
