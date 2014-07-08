# A script in Julia to enumerate all DNA 6-mers and determine how
# close they are to certain Illumina barcodes.

using Iterators

x = ['A','C','T','G']

p = product([x for _ in 1:6]...)

barcodes = [i for i in p]

erccpos=[   "GCCAAT",
            "CTTGTA"]

erccneg= [  "CAGATC",
            "CGATGT",
            "GTGAAA"]

function lev(s1::ASCIIString, s2::ASCIIString)
  if length(s1) < length(s2)
    return lev(s2,s1)
  end

  if length(s2) == 0
    return length(s1)
  end

  previous_row = [0:length(s2)]
  for (i,c1) in enumerate(s1)
    current_row = [i]
    for (j,c2) in enumerate(s2)
      insertions = previous_row[j+1] + 1
      deletions = current_row[j] + 1
      substitutions = previous_row[j] + (c1 != c2 ? 1 : 0)
      push!(current_row,min(insertions, deletions, substitutions))
    end
    previous_row = current_row
  end
  previous_row[end]
end

dists = [(min([lev(x,b) for b in erccpos]), min([lev(x,b) for b in erccneg])) for x in barcodes]

for f in [<,(==),>]
  println(sum(1*map(x->f(x[1],x[2]),dists))/length(barcodes))
end

