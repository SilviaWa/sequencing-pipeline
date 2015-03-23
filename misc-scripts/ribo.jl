using HDF5,JLD
blas_set_num_threads(1)

if length(ARGS) < 3 || !isdir(ARGS[2])
    println("""ERROR: Improper usage:
    ribo.jl <species> <location of reference> <files...>
    The script needs to be run from the directory with htseq.list inside of it.
    This script will compare the list of gene (counts) to the Ensembl GTF and
    determine the number of ribosomal counts. gtf_runner.jl needs to be run
    against the genome first before this script can be run.""")
    quit(-1)
end

species = ARGS[1]
refdir = ARGS[2]
pnames = ARGS[3:end]

# @load joinpath(refdir, "gtfdata.jld") idset nameset biotypes idbiotype namebiotype id2name name2id exoncount
@load joinpath(refdir, "gtfdata.jld") namebiotype

basepath = pwd()

for pname in pnames
  path = joinpath(pname, "star", species)
  assert(isdir(path))

  isfile(joinpath(path, "rrna.count")) && continue

  cd(path)

  samp = open("htseq.list")
  rrnafid = open("rrna.list", "w")
  rrnacount = 0

  for line in eachline(samp)
      gene,num = split(line)
      if beginswith(namebiotype[gene], "rRNA")
          write(rrnafid, line)
          rrnacount += parse(num)
      end
  end

  open(x->write(x, string(rrnacount)), "rrna.count", "w")

  close(rrnafid)
  close(samp)
  cd(basepath)
end
