#setdep @node|GAA@

#define midSD !(puts -nonewline "[expr -@Lg@/2 -@Lsd@/2 -@Lsp@]")!
#define midCh 0
IOControls {
        EnableTools
        inputFile =  "@[relpath n@node|GAA@_fps.tdr]@"
        outputFile = "n@node@_slice_msh.tdr"
        saveInterfaceRegions = true 
}

Tools {

  Slice {
    normal = (0 0 1)
    location = (0 0 midCh)
  }

}



