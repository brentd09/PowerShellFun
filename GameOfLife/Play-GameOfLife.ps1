function next-gen{
  param([System.Array]$origM)

  $tmpM = $origM

  For($x=0; $x -lt $tmpM.GetUpperBound(0); $x++ ){
      For($y=0; $y -lt $tmpM.GetUpperBound(1); $y++){
          $neighborCount = getNeighbors $tmpM $x $y
          if($neighborCount -lt 2 -OR $neighborCount -gt 3){
              $tmpM[$x,$y] = 0
          }
          elseif($neighborCount -eq 3){
              $tmpM[$x, $y] = 1
          }
      } 
  }
  $Global:origM = $tmpM
}

function getNeighbors{
  param(
      [System.Array]$g,
      [Int]$x,
      [Int]$y
  )
  $newX=0
  $newY=0
  $count=0

  for($newX = -1; $newX -le 1; $newX++){
      for($newY = -1; $newY -le 1; $newY++){
          if($g[$(wrap $x $newX),$(wrap $y $newY)]){
              $count++
          }
      }
  }
  return $count
}

function wrap{
  param(
      [Int]$z,
      [Int]$zEdge
  )

  $z+=$zEdge
  If($z -lt 0){
      $z += $size
  }
  ElseIf($z -ge $size){
      $z -= $:size
  }
  return $z
}

function printBoard{
  0..$m.GetUpperBound(0) | 
  % { $dim1=$_; (0..$m.GetUpperBound(1) | % { $m[$dim1, $_] }) -join ' ' }
  write-host ""
}
#board is always a square, size represents both x and y
$size = 20

$m = New-Object 'int[,]' ($size, $size)
$m[2,1] = 1
$m[2,2] = 1
$m[2,3] = 1


printBoard

For($x=0; $x -lt 1; $x++){
  Clear-Host
  next-gen $m
  printBoard
  write-host ""
}