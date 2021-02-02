# scatac_motif_analysis

This pipeline runs HOMER on single-cell ATAC-seq data to find motifs ([`findMotifsGenome.pl`](http://homer.ucsd.edu/homer/motif/)) and annotate peaks ([`annotatePeaks.pl`](http://homer.ucsd.edu/homer/ngs/annotation.html)) in a cell type-specific manner. This pipeline assumes that you have peak calling outputs from MACS for each of your cell types and samples. To run this pipeline on your data, make modifications to the config file such that the parameters describe your own data. Alternatively, make changes to the Snakefile itself for greater flexibility. Then execute the pipeline as you would any other Snakemake pipeline.

## Input data
This pipeline assumes that you have peak calling outputs from MACS for each of your cell types and samples. This is because it will generate a BED file from each `.narrowPeak` output file and prepend `chr` to each chromosome in the first column. If your `.narrowPeak` files already have `chr` in the first column, then you may want to modify the shell command in the `parse_bed` rule of the Snakefile.

This pipeline also assumes that your input data are ordered in a certain way. E.g.:
```bash
├── SampleA
│   ├── Celltype1
│   │   ├── Celltype1_control_lambda.bdg
│   │   ├── Celltype1_peaks.narrowPeak
│   │   ├── Celltype1_peaks.xls
│   │   ├── Celltype1_summits.bed
│   │   └── Celltype1_treat_pileup.bdg
│   ├── Celltype2
│   │   ├── Celltype2_control_lambda.bdg
│   │   ├── Celltype2_peaks.narrowPeak
│   │   ├── Celltype2_peaks.xls
│   │   ├── Celltype2_summits.bed
│   │   └── Celltype2_treat_pileup.bdg
//  //  
│   ├── CelltypeN
│   │   ├── CelltypeN_control_lambda.bdg
│   │   ├── CelltypeN_peaks.narrowPeak
│   │   ├── CelltypeN_peaks.xls
│   │   ├── CelltypeN_summits.bed
│   │   └── CelltypeN_treat_pileup.bdg
├── SampleB
│   ├── Celltype1
│   │   ├── Celltype1_control_lambda.bdg
│   │   ├── Celltype1_peaks.narrowPeak
│   │   ├── Celltype1_peaks.xls
│   │   ├── Celltype1_summits.bed
│   │   └── Celltype1_treat_pileup.bdg
│   ├── Celltype2
│   │   ├── Celltype2_control_lambda.bdg
│   │   ├── Celltype2_peaks.narrowPeak
│   │   ├── Celltype2_peaks.xls
│   │   ├── Celltype2_summits.bed
│   │   └── Celltype2_treat_pileup.bdg
//  //  
│   ├── CelltypeN
│   │   ├── CelltypeN_control_lambda.bdg
│   │   ├── CelltypeN_peaks.narrowPeak
│   │   ├── CelltypeN_peaks.xls
│   │   ├── CelltypeN_summits.bed
│   │   └── CelltypeN_treat_pileup.bdg
├── SampleC
│   ├── Celltype1
│   │   ├── Celltype1_control_lambda.bdg
│   │   ├── Celltype1_peaks.narrowPeak
│   │   ├── Celltype1_peaks.xls
│   │   ├── Celltype1_summits.bed
│   │   └── Celltype1_treat_pileup.bdg
│   ├── Celltype2
│   │   ├── Celltype2_control_lambda.bdg
│   │   ├── Celltype2_peaks.narrowPeak
│   │   ├── Celltype2_peaks.xls
│   │   ├── Celltype2_summits.bed
│   │   └── Celltype2_treat_pileup.bdg
//  //  
│   ├── CelltypeN
│   │   ├── CelltypeN_control_lambda.bdg
│   │   ├── CelltypeN_peaks.narrowPeak
│   │   ├── CelltypeN_peaks.xls
│   │   ├── CelltypeN_summits.bed
│   │   └── CelltypeN_treat_pileup.bdg
```

## [`config.yml`](https://github.com/zrcjessica/scatac_motif_analysis/blob/main/config.yml)
Fill out each of the fields in the `config.yml` file such that they describe your data.

### [`out`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L1)
Path to output directory where outputs of HOMER are saved

### [`tmp`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L2)
This is where BED files generated from the `.narrowPeak` files are saved. Option to delete these BED files when pipeline completes. 

### [`clean`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L42)
If `True`, remove the BED files generated from each `.narrowPeak` file when the pipeline completes. 

### [`homer_dir`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L5)
Path to directory where HOMER scripts are located

### [`samples`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L7)
List of sample names in your dataset. Sample names must correspond to the names of the directories containing cell type-specific MACS outputs (see [above](https://github.com/zrcjessica/scatac_motif_analysis/blob/main/README.md#input-data)). 

### [`celltypes`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L11)
List of cell types to be analyzed. This script is designed such that it will analyze the same cell types across all samples. If you would like to analyze different cell types for each sample, you should make modifications to the Snakefile. 

### [`peaks_dir`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L29)
This is the directory where the MACS output for each sample and cell type are saved. 

### [`genome`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L32)
This is the `<genome>` argument for `findMotifsGenome.pl`. See [HOMER docs](http://homer.ucsd.edu/homer/ngs/peakMotifs.html) for more info.

### [`window_sizes`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L33)
This is the value for the `-size` argument of `findMotifsGenome.pl`. Can give a single value or a list of values if you would like to run the analysis with different window sizes. See [HOMER docs](http://homer.ucsd.edu/homer/ngs/peakMotifs.html) for more info.

### [`background`](https://github.com/zrcjessica/scatac_motif_analysis/blob/8b80306c4ee164c16417505e4cb37e4d7fc87a3d/config.yml#L38)
Set to `True` if you would like to run `findMotifsGenome.pl` with a background set of peaks. For each cell type under each sample, this pipeline will create a background set of peaks comprised of peaks observed in all other cell types of that same sample.

