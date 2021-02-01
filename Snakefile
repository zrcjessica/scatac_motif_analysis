configfile: "config.yml"

targets = []

motifs_outs = expand(config['out'] + "/findMotifs/{sample}/{window}/{celltype}_motifs",
			sample = config['samples'], celltype = config['celltypes'],
			window = config['window_sizes'])
targets.extend(motifs_outs)

annotate_outs = dynamic(
	expand(
		config['out'] + "/annotatePeaks/{sample}/{window}/{celltype}/{{motif}}.{ext}",
		sample = config['samples'], window = config['window_sizes'], 
		celltype = config['celltypes'], ext = ['tsv', "tsv.log"]
		)
	)
targets.extend(annotate_outs)

if config['background']:
	targets.append(
		expand(config['out'] + "/background/{sample}/{celltype}_bg.bed", \
		sample = config['samples'], celltype = config['celltypes']
			)
		)
if config['clean']:
	targets.extend(
		expand(
			config['out'] + "/{sample}-{celltype}_clean.done",
			sample = config['samples'], celltype = config['celltypes']
			)
		)

rule all:
	input: targets

if config['background']:
	rule make_background:
		input: expand(config['peaks_dir'] + "/{sample}/{celltype}/{celltype}_peaks.narrowPeak",\
			celltype = config['celltypes'], allow_missing = True)
		output: expand(config['out'] + "/background/{sample}/{celltype}_bg.bed",\
			celltype = config['celltypes'], allow_missing = True)
		params: 
			outdir = config['out'] + "/background/{sample}"
		conda: "env.yml"
		shell: 
			"Rscript scripts/make_background_bed.R --files {input} "
			"--celltypes {config[celltypes]} --outdir {params.outdir}"

# make bed file from narrowPeak files(MACS2 output) with chr in seqnames
rule parse_bed:
	input: config['peaks_dir'] + "/{sample}/{celltype}/{celltype}_peaks.narrowPeak"
	output: config['tmp'] + "/{sample}-{celltype}_peaks.bed"
	shell:
		"""
		cut -f1-6 {input} > {output} && \
		sed -i -e 's/^/chr/' {output}
		"""

if config['background']:
	rule findMotifs:
		input: 
			bedfile = rules.parse_bed.output[0],
			bg_peaks = rules.make_background.output[0]
		output: directory(config['out'] + "/findMotifs/{sample}/{window}/{celltype}_motifs")
		params: 
			genome = config['genome'],
			# bg = config['out'] + "/background/{sample}/{celltype}_bg.bed",
			script = config['homer_dir'] + "/findMotifsGenome.pl"
		shell: 
			"""
			{params.script} {input.bedfile} \
			{params.genome} {output} -bg {input.bg_peaks} -size {wildcards.window} -mask
			"""
else:
	rule findMotifs:
		input: rules.parse_bed.output[0]
		output: directory(config['out'] + "/findMotifs/{sample}/{window}/{celltype}_motifs")
		params: 
			genome = config['genome'],
			script = config['homer_dir'] + "/findMotifsGenome.pl"
		shell: 
			"""
			{params.script} {input} \
			{params.genome} {output} -size {wildcards.window} -mask
			"""

if config['clean']:
	input: rules.parse_bed.output[0]
	output: touch(config['out'] + "/{sample}-{celltype}_clean.done")
	shell: "rm {input}"

rule annotate_peaks:
	input: rules.findMotifs.output[0] 
	output: 
		res = dynamic(config['out'] + "/annotatePeaks/{sample}/{window}/{celltype}/{motif}.tsv"),
		log = dynamic(config['out'] + "/annotatePeaks/{sample}/{window}/{celltype}/{motif}.tsv.log")
	params: 
		genome = config['genome'],
		outdir = config['out'] + "/annotatePeaks/{sample}/{window}/{celltype}",
		script = config['homer_dir'] + "/annotatePeaks.pl"
	shell:
		"""
		mkdir -p {params.outdir} && 
		for m in {input}/*/*.motif; do
			n="$(basename $m .motif)"
			echo $n
			  if [[ ! -f $m.tsv ]]
			  then
			    {params.script} \
			    tss {params.genome} \
			    -size -500,250 -m $m \
			    1> {params.outdir}/$n.tsv 2> {params.outdir}/$n.tsv.log
			  fi
		done
		"""

