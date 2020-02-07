# SkewC
SkewC a novel quality-assessment method to identify poor quality single-cells in scRNA-seq experiments. The method relies on the measure of skewness of the gene coverage of each single cell as a quality measure.
This folder contains several R Markdowns, 
1-	SkewC_Create_Coverage_Matrix.Rmd >> you need to source emtab2600_verctor_normalized_coverage_values.R
2-	SkewC_Compute_Matrix_Mean.Rmd
3-	SkewC_PlotGene_Body_Coverage.Rmd
4-	SkewC_TrimClustering.Rmd  >> you need the following rds   coverageDF_filtered.rds 
Please run them in the same sequence as above. 
