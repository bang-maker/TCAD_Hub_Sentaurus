set Ncol 3
set CSV(Header,0) "A"
set CSV(Header,1) "B"
set CSV(Header,2) "C"
set CSV(Data,0) [list 1.1 1.2 1.3 1.4]
set CSV(Data,1) [list 2.1 2.2 2.3 2.4]
set CSV(Data,2) [list 3.1 3.2 3.3 3.4]

ifm::WriteCSV -csv CSV -ncol Ncol -file "my.csv"

ifm::ReadCSV -out ReadCSV -ncol ReadNcol -file "my.csv"
for {set icol 0} {$icol < $ReadNcol} {incr icol} {
    puts "Column name is: $ReadCSV(Header,$icol)"
    puts "Column data is: $ReadCSV(Data,$icol)"
}
#-> Column name is: A
#-> Column data is: 1.1 1.2 1.3 1.4
#-> Column name is: B
#-> Column data is: 2.1 2.2 2.3 2.4
#-> Column name is: C
#-> Column data is: 3.1 3.2 3.3 3.4