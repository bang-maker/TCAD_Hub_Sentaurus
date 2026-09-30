###--------------------------------------------------------------------
puts "\n2.1 Simple Variables"
### 2.1.a
set i  3
set q  1.6e-19
set W  "Hello World"

### 2.1.b
puts "The value of i is $i"
#-> The value of i is 3

puts "The elementary charge is $q C"
#-> The elementary charge is 1.6e-19 C

puts "The string W contains >$W<"
#-> The string W contains >Hello World<

### 2.1.c
puts "The ${i}rd value"
#-> The 3rd value

###--------------------------------------------------------------------
puts "\n2.2 Arithmetic Expressions"

### 2.2.a
set j   [expr $i+5]
puts "$i + 5 is $j"
#-> 3 + 5 is 8

set pi [expr 2.0*asin(1.0)]
puts "pi = $pi"
#-> pi = 3.141592653589793

set SIN [expr sin($pi/4.0)]
puts "sin(pi/4.0) is $SIN"
#-> sin(pi/4.0) is 0.7071067811865475

### 2.2.b
puts [expr 1/2]
#-> 0

puts [expr 1/2.0]
#-> 0.5

###--------------------------------------------------------------------
puts "\n2.3 Strings"

###
set MyString "Hello World"
set MyVariable {This is the string}
puts $MyString
#->Hello World
puts $MyVariable
#->This is the string

###
set SingleWordString Hello

###
append SingleWordString "!"
puts "append SingleWordString \"!\": $SingleWordString"
#-> Hello!

###
string length $MyString
puts "string length \"$MyString\": [string length $MyString]"
#-> 11

###
string index $MyString 6
puts "string index \"$MyString\" 6: [string index $MyString 6]"
#-> W

###
string range $MyString 3 7
puts "string range \"$MyString\" 3 7: [string range $MyString 3 7]"
#-> lo Wo

###
string equal -nocase "hello" "HeLlO"
puts "string equal -nocase \"hello\" \"HeLlO\": [string equal -nocase "hello" "HeLlO"]"
#-> 1

###
string match "*ello*" $MyString
puts "string match \"*ello*\" \"$MyString\": [string match "*ello*" $MyString]"
#-> 1

string match "Hell" $MyString
puts "string match \"Hell\" \"$MyString\": [string match "Hell" $MyString]"
#-> 0

string match "hell*" $MyString
puts "string match \"hell*\" \"$MyString\": [string match "hell*" $MyString]"
#-> 0

string match -nocase "hell*" $MyString
puts "string match -nocase \"hell*\" \"$MyString\": [string match -nocase "hell*" $MyString]"
#-> 1

###
set StringToTrim " abcba "
string trim $StringToTrim
puts "string trim \"$StringToTrim\": [string trim $StringToTrim]"
#-> abcba

string trim $StringToTrim " a"
puts "string trim \"$StringToTrim\" \" a\": [string trim $StringToTrim  " a"]"
#-> bcb

string trimleft $StringToTrim " a"
puts "string trimleft \"$StringToTrim\" \" a\": [string trimleft $StringToTrim  " a"]"
#-> bcba

string trimright $StringToTrim "a "
puts "string trimright \"$StringToTrim\" \"a \": [string trimright $StringToTrim  "a "]"
#-> abcb 

###
set string2 "tutorial"
string first "o" $string2
puts "string first \"o\" $string2: [string first "o" $string2]"
#-> 3

string last "t" $string2
puts "string last \"t\" $string2: [string last "t" $string2]"
#-> 2

###
string tolower $MyString
puts "string tolower \"$MyString\": [string tolower $MyString]"
#-> hello world

string toupper $MyString
puts "string toupper \"$MyString\": [string toupper $MyString]"
#-> HELLO WORLD


###--------------------------------------------------------------------
puts "\n2.4 Lists"

### 2.4.a
set ABCList   [list a b c d e]
set NUMList   [list 1 2 3 4 5 6]
set STRList   [list This sentence is a TCL list]
set MIXList   [list a 2 3.1415 TCL ?]
set EMPTYList [list]

### 2.4.b
puts $ABCList
#-> a b c d e
  
puts $NUMList
#-> 1 2 3 4 5 6
    
puts $STRList 
#-> This sentence is a TCL list
    
puts $MIXList
#-> a 2 3.1415 TCL ?

### 2.4.c
set LENGTH [llength $ABCList]
puts "ABCList contains $LENGTH elements."
#-> ABCList contains 5 elements

### 2.4.d 
puts "The first element of ABCList is:  [lindex $ABCList 0]"
#-> The first element of ABCList is:  a
    
puts "The second element of NUMList is: [lindex $NUMList 1]"
#-> The second element of NUMList is: 2
   
puts "The last element of MIXList is:   [lindex $MIXList end]"
#-> The last element of MIXList is:   ?
    
puts "The next to last element of ABCList is \
      [lindex $ABCList [expr $LENGTH -2]]"
#-> The next to last element of ABCList is  d
    
set SUBList [lrange $STRList 1 3]
puts "The second to fourth elements of STRList are >$SUBList<"
#->  The second to fourth elements of STRList are >sentence is a<   

### 2.4.e
set cIndex [lsearch $ABCList "c"]
puts "The letter c has the index $cIndex"
#-> The letter c has the index 2

### 2.4.f 
set NewElement f
lappend ABCList $NewElement

### 2.4.g
set UnsortedList [list 45.1 78.6 12.6 1.5 89.4 11.6]
set SortedList   [lsort -real $UnsortedList]
puts $SortedList
#-> 1.5 11.6 12.6 45.1 78.6 89.4  

### 2.4.h
set UnsortedList [list {a 45.1 1} {g 78.6 5} {r 12.6 8} \
                       {c  1.5 2} {q 89.4 3} {n 11.6 4}]
set SortedList_0   [lsort -index 0 -ascii $UnsortedList]
puts $SortedList_0
#-> {a 45.1 1} {c  1.5 2} {g 78.6 5} {n 11.6 4} {q 89.4 3} {r 12.6 8}
    
set SortedList_1   [lsort -index 1 -real $UnsortedList]
puts $SortedList_1
#-> {c  1.5 2} {n 11.6 4} {r 12.6 8} {a 45.1 1} {g 78.6 5} {q 89.4 3}    

set SortedList_2   [lsort -index 2 -integer $UnsortedList]
puts $SortedList_2
#-> {a 45.1 1} {c  1.5 2} {q 89.4 3} {n 11.6 4} {g 78.6 5} {r 12.6 8}

###--------------------------------------------------------------------
puts "\n2.5 Loops"

### 2.5.a
foreach NUM $NUMList CHAR $ABCList {
  puts "The ${NUM} letter of the alphabet is $CHAR"
}
#-> The 1 letter of the alphabet is a
#-> The 2 letter of the alphabet is b
#-> The 3 letter of the alphabet is c
#-> The 4 letter of the alphabet is d
#-> The 5 letter of the alphabet is e
#-> The 6 letter of the alphabet is f   

### 2.5.b
for { set i 0 } { $i <= 10 } { incr i } {
  puts -nonewline " i=$i "
}
#-> i=0  i=1  i=2  i=3  i=4  i=5  i=6  i=7  i=8  i=9  i=10 

### 2.5.c
set f 1.0
set x 0.0
while { $f > 0.0 } {
   set x [expr $x + 0.01]
   set f [expr 1.0 - $x*$x]   
}
puts "Zero crossing is at x= $x"
#-> Zero crossing is at x= 1.0 

### 2.5.d
for {set i 0} {$i<=100} {incr i} {
  if {[expr fmod($i, 2)] == 0} {
    continue
  } elseif {$i > 6} {
    break
  } 
  puts $i
}
#-> 1
#-> 3
#-> 5

###--------------------------------------------------------------------
puts "\n2.5 Arrays"

### 2.6.a
set model(1) Fermi
set model(2) Constant
set model(3) 3Stream
set model(4) 5Stream

for { set i 1 } { $i <= 4 } { incr i } {
  puts "Model #$i is $model($i)"
}
#-> Model #1 is Fermi
#-> Model #2 is Constant
#-> Model #3 is 3Stream
#-> Model #4 is 5Stream

### 2.6.b
set Identifiers [list first second third fourth]
set model(first)  Fermi
set model(second) Constant
set model(third)  3Stream
set model(fourth) 5Stream

foreach i $Identifiers {
  puts "The $i model is $model($i)"
}
#-> The first model is Fermi
#-> The second model is Constant
#-> The third model is 3Stream
#-> The fourth model is 5Stream

###--------------------------------------------------------------------
puts "\n2.7 Conditional branching"

### 2.7.a
set val 1
if { $val == 0 } {
   puts "val is 0"
} elseif { $val > 2 } {
   puts "val is larger than 2"
} else {
   puts "val is negative or one"
}
#-> val is negative or one

### 2.7.b
set MODEL Fermi      
switch $MODEL {
  Constant { puts "Use constant diffusion model" }
  Fermi    { puts "Use Fermi diffusion model"}
}
#-> Use Fermi diffusion model

###--------------------------------------------------------------------
puts "\n2.8 Logical operators"

### 2.8.a
set Vd 1.5
set Device "pMOS"
set Simulation "IV"

if { $Vd < 0.1 && $Device == "nMOS"  &&  $Simulation != "BV" } {
   puts "Simulate nMOS IdVg in linear regime"
} elseif { $Vd > 0.1 && $Device == "pMOS"  &&  ! ($Simulation == "BV") } {
   set Vd [expr -1.0*$Vd]
   puts "Simulate pMOS IdVg for Vd=$Vd"
} elseif { $Simulation == "BV" || $Device == "BJT" } {
   puts "Simulate BJT or MOS breakdown"
} else {
   puts "None of the specified conditions are met..."
}
#-> Simulate pMOS IdVg for Vd=-1.5

###--------------------------------------------------------------------
puts "\n2.9 Assignment"

### 2.9.a
set freqList [list 1.00e5  2.15e5  4.64e5  1.00e6  2.15e6  4.64e6  \
                   1.00e7  2.15e7  4.64e7  1.00e8  2.15e8  4.64e8  \
                   1.00e9  2.15e9  4.64e9  1.00e10 2.15e10 4.64e10 \
                   1.00e11 2.15e11 4.64e11 1e+12 ]

set h21List  [list 33.62   33.62   33.62   33.62   33.62   33.62   \
                   33.62   33.61   33.59   33.46   32.86   30.48   \
                   23.74   14.12    7.06    3.34   1.57    0.75    \
                    0.38    0.19    0.20    0.23 ]

### 2.9.b
set h21dBList  [list]
set h21first   [lindex $h21List 0]
set h21dBfirst [expr 20*log10($h21first)]
set ThreedB    [expr $h21dBfirst - 3]
set Flag 0

foreach h21 $h21List freq $freqList {
  set h21dB [expr 20*log10($h21)]
  lappend h21dBList $h21dB
    if { $h21dB  <=  $ThreedB && $Flag == 0} then {
      set freq3dB [expr 1e-9*$freq]     
      set Flag 1
    }
  puts "$freq $h21dB"
}
puts ""
puts "The three dB point occurs at $freq3dB Ghz"

###--------------------------------------------------------------------
puts "\n3.1 File input and output"

### 3.1.a
set FIDw [open Writing.tmp "w"]

### 3.1.b
puts $FIDw "This is the first line of this file"
puts $FIDw $ABCList

### 3.1.c
close $FIDw

### 3.1.d
set FIDr [open Writing.tmp "r"]

### 3.1.e
while { [gets $FIDr NewLine] > 0 } {
  puts $NewLine
}
close $FIDr
#-> This is the first line of this file
#-> a b c d e f   

### 3.1.f
set FIDr [open Writing.tmp "r"]
set DATA [read $FIDr]
puts $DATA
close $FIDr
#-> This is the first line of this file
#-> a b c d e f   

###--------------------------------------------------------------------
puts "\n3.2 Formatting output"

### 3.2.a
set  pi [ expr 2.0*asin(1.0) ]
puts "Pi unformated: $pi"
#-> Pi unformated: 3.141592653589793

puts "Pi with 2 digits: [format %.2f $pi]"
#-> Pi with 2 digits: 3.14

puts "Pi in exponential format: [format %.4e $pi]" 
#-> Pi in exponential format: 3.1416e+00

set i 24
puts "Integer with leading zeros: >[format %05d $i]<"
#-> Integer with leading zeros: >00024<

puts "Integer with leading blanks:>[format %5d $i]<" 
#-> Integer with leading zeros: >   24<

###--------------------------------------------------------------------
puts "\n3.3 Procedures"

### 3.3.a
proc Arrhenius { A0 E } {
  global T
  set k 8.62e-5 ; # eV/K
  set A [expr $A0*exp(-$E/($k*$T))]
  return $A
}

### 3.3.b
set T 300
set A [Arrhenius 1e5 1.0]
puts "The Arrhenius expression gives: [format %.4e $A]"
#-> The Arrhenius expression gives: 1.6067e-12

###--------------------------------------------------------------------
puts "\n3.4 Masking special characters, substitutions"

### 3.4.a 
set T 400.0
set CMD_Static "[Arrhenius 1e5 1.0]"
puts [format "\[Arrhenius 1e5 1.0\] gives %.4e" $CMD_Static]
#-> [Arrhenius 1e5 1.0] gives 2.5378e-08

set T 1100.0
puts [format "\[Arrhenius 1e5 1.0\] gives %.4e" $CMD_Static]
#-> [Arrhenius 1e5 1.0] gives 2.5378e-08

### 3.4.b
set T 400.0
set CMD_Dynamic "\[Arrhenius 1e5 1.0\]"
puts $CMD_Dynamic
#-> [Arrhenius 1e5 1.0]
puts [format %.4e [expr $CMD_Dynamic]]
#-> 2.5378e-08

set T 1100.0
puts [format %.4e [expr $CMD_Dynamic]]
#-> 2.6291e+00

###--------------------------------------------------------------------
puts "\n3.5 Files and Directories"

### 3.5.a
set FIDw [open TMP_1.tmp "w"]
puts $FIDw "test"
close $FIDw

set FIDw [open TMP_2.tmp "w"]
puts $FIDw "test"
close $FIDw
       
set FILES [glob "TMP*"]
puts "$FILES"
#-> TMP_1.tmp TMP_2.tmp    

### 3.5.b
set FILE [lindex $FILES 0]      
set STEM [file rootname $FILE]
puts "The rootname is: $STEM"
#-> The rootname is: TMP_1
set EXT  [file extension $FILE]
puts "The extension is: $EXT"
#->  The extension is: .tmp

### 3.5.c
set CWD [pwd]
puts $CWD

### 3.5.d
set PATH [file dirname $CWD]
puts "Path is: $PATH"
     
set DIR [file tail $CWD]
puts "Directory is: $DIR"

###--------------------------------------------------------------------
puts "\n3.6 System Calls"

### 3.6.a
exec rm -f Writing.tmp

### 3.6.b
set FILE source.tcl
eval exec rm -f $FILE

### 3.6.c
set ls_output [exec ls]
puts "The output of the ls command is:"
puts $ls_output

###--------------------------------------------------------------------
puts "\n3.7 Error handling"

### 3.7.a
set Nom 0.0
set Denom 10.0

if { [catch { set result [expr $Denom/$Nom]} ErrCode]  != 0 } {
  puts "An Error occured. The Error code is >$ErrCode<"
} else {
  puts "$Denom/$Nom = $result"
}
#-> An Error occured. The Error code is >divide by zero<

###--------------------------------------------------------------------
puts "\n3.8 String Manipulations"

### 3.8.a
set STRING "Silicon \"substrate\" \{ rectangle \[(0.0,-0.5) (1.0,0.5)\] \}"

### 3.8.b
set itmp       [expr [string first " " $STRING]]
set MATERIAL   [string range $STRING 0 [expr $itmp -1]]

set istart     [expr [string first "\"" $STRING]]
set iend       [expr [string last  "\"" $STRING]]
set REGION     [string range $STRING [expr $istart+1] [expr $iend -1]]

puts "The material is: $MATERIAL"
#-> The material is: Silicon
puts "The region name is: $REGION"
#-> The region name is: substrate     

### 3.8.c
set istart     [expr [string first "(" $STRING]]
set iend       [expr [string first "," $STRING]]
set X0         [string range $STRING [expr $istart+1] [expr $iend -1]]

set istart     [expr [string first "," $STRING]]
set iend       [expr [string first ")" $STRING]]
set Y0         [string range $STRING [expr $istart+1] [expr $iend -1]]

set istart     [expr [string last "(" $STRING]]
set iend       [expr [string last "," $STRING]]
set X1         [string range $STRING [expr $istart+1] [expr $iend -1]]

set istart     [expr [string last "," $STRING]]
set iend       [expr [string last ")" $STRING]]
set Y1         [string range $STRING [expr $istart+1] [expr $iend -1]]

### 3.8.d
set NewString ${MATERIAL}_${REGION}
puts $NewString
#-> Silicon_substrate      

### 3.8.e
set Text "$NewString extends from "
append Text "X= $X0 to $X1 "
append Text "and from "
append Text "Y= $Y0 to $Y1."
puts $Text
#-> Silicon_substrate extends from X= 0.0 to 1.0 and from Y= -0.5 to 0.5.

### 3.8.f
set NAME1 "Eva"
set NAME2 "Adam"
if { [string compare $NAME1 $NAME2] == 0 } {
   puts "Both names are the same"
} elseif { [string compare $NAME1 $NAME2] < 0 } {
    puts "$NAME1 comes before $NAME2"
}  elseif { [string compare $NAME1 $NAME2] > 0 } {
    puts "$NAME2 comes before $NAME1"
}
#-> Adam comes before Eva     

### 3.8.g
set DEV "HV NMOStransistor"
if { [string match "*NMOS*" $DEV] } { 
    puts "This device is an NMOS"
} else {
    puts "This device is NOT an NMOS"
}
#-> This device is an NMOS    

### 3.8.h
set OLDString "HV NMOStransistor"
set OLDPattern "NMOS"
set NEWPattern "PFET"

set NEWString [regsub $OLDPattern $OLDString $NEWPattern] 

puts "NEW String: $NEWString"
#-> NEW String: HV PFETtransistor

### 3.8.i
set String "1 2 3 4"
set SUM 0
foreach Number $String {
 set SUM [expr $SUM+$Number]
}
puts $SUM
#-> 10     

### 3.8.j
set String "1,2,3,4"
set List [split $String ","]

set SUM 0
foreach Number $List {
 set SUM [expr $SUM+$Number]
}
puts $SUM
#-> 10     


###--------------------------------------------------------------------
puts "\n3.9 Assignment"

### 3.9.a
# Open the file
set FIDr [open @pwd@/vtrolloff.txt "r"]

# Read in first line with header information
gets $FIDr NewLine
set NewList [split $NewLine ","]

set Index(Lg) 0
set Index(Vd) 1
set Index(Vti) 2

# Initialize the target list of list
set LinList [list]
set SatList [list]

# Read in the data line by line and process it
while { [gets $FIDr NewLine] > 0 } {

# Turn the comma separated line into a TCL list
  set NewList [split $NewLine ","]

# Read the enties Lg, Vd, and Vti
  set Lg  [lindex $NewList $Index(Lg)]
  set Vd  [lindex $NewList $Index(Vd)]    
  set Vti [lindex $NewList $Index(Vti)]    

# Create a list for low and high drain bias Vt's, which contains
# Lg-Vti pairs as entries
  if { $Vd < 0.1 } {
    lappend LinList [list $Lg $Vti]
  } else {
    lappend SatList [list $Lg $Vti]
  }
}
close $FIDr

# Sort the lists by Lg
set LinSort [lsort -index 0 -integer $LinList]
set SatSort [lsort -index 0 -integer $SatList]

set DIBLList [list]
foreach Lin $LinSort Sat $SatSort {
  set LgLin [lindex $Lin 0]
  set LgSat [lindex $Sat 0]
  if { $LgLin != $LgSat } {
    puts "Inconsistent Lg values: $LgLin $LgSat"
  }  
  set VtLin [lindex $Lin 1]
  set VtSat [lindex $Sat 1]
  set DIBL [expr 1e3*($VtLin - $VtSat)]
  puts "DIBL at Lg=$LgLin is [format %.1f $DIBL] mV"
}

###------------------
puts "THE END"
