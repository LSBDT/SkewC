#Rscript --vanilla bin/SkewC.r cellranger5/GSE143607/GSE143607.r plot GSE143607
#Rscript --vanilla bin/SkewC.r cellranger5/fixed_neurons_2000/fixed_neurons_2000.r plot fixed_neurons_2000
#Rscript --vanilla bin/SkewC.r cellranger5/fixed_neurons_6days_2000/fixed_neurons_6days_2000.r plot fixed_neurons_6days_2000
#Rscript --vanilla bin/SkewC.r cellranger5/neuron_9k/neuron_9k.r plot neuron_9k
#Rscript --vanilla bin/SkewC.r cellranger5/neurons_2000/neurons_2000.r plot neurons_2000
#Rscript --vanilla bin/SkewC.r cellranger5/neurons_900/neurons_900.r plot neurons_900
#Rscript --vanilla bin/SkewC.r cellranger5/nuclei_2k/nuclei_2k.r plot nuclei_2k
#Rscript --vanilla bin/SkewC.r cellranger5/nuclei_900/nuclei_900.r plot nuclei_900
#Rscript --vanilla bin/SkewC.r cellranger5/pbmc4k/pbmc4k.r plot pbmc4k
#Rscript --vanilla bin/SkewC.r cellranger5/pbmc8k/pbmc8k.r plot pbmc8k
#Rscript --vanilla bin/SkewC.r cellranger5/t_3k/t_3k.r plot t_3k
#Rscript --vanilla bin/SkewC.r cellranger5/t_4k/t_4k.r plot t_4k
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Human_dataset/E-MTAB-3929/E-MTAB-3929_Coverage.r plot E_MTAB_3929
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Human_dataset/GSE64016/GSE64016_Coverage.r plot GSE64016
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Human_dataset/GSE70151/GSE70151_Coverage.r plot GSE70151
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Human_dataset/GSE75748/GSE75748_Coverage.r plot GSE75748
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Human_dataset/PRJEB8994/PRJEB8994_Coverage.r plot PRJEB8994
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-2512/E-MTAB-2512_Coverage.r plot E_MTAB_2512
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-2600/E-MTAB-2600_Coverage.r plot E_MTAB_2600
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-2805/E-MTAB-2805_Coverage.r plot E_MTAB_2805
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-3857/E-MTAB-3857_Coverage.r plot E_MTAB_3857
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-4619/E-MTAB-4619_Coverage.r plot E_MTAB_4619
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE29087/GSE29087_Coverage.r plot GSE29087
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE42268/GSE42268_Coverage.r plot GSE42268
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE45719/GSE45719_Coverage.r plot GSE45719
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE46980/GSE46980_Coverage.r plot GSE46980
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE53386/GSE53386_Coverage.r plot GSE53386
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE54695/GSE54695_Coverage.r plot GSE54695
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE56638/GSE56638_Coverage.r plot GSE56638
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE59114/GSE59114_Coverage.r plot GSE59114
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE67310/GSE67310_Coverage.r plot GSE67310
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE68981/GSE68981_Coverage.r plot GSE68981
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE70657/GSE70657_Coverage.r plot GSE70657
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE74833/GSE74833_Coverage.r plot GSE74833
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE75659/GSE75659_Coverage.r plot GSE75659
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/GSE98664/GSE98664_Coverage.r plot GSE98664
#Rscript --vanilla bin/SkewC.r SkewC_Non10x_datasets/Mouse_dataset/PRJDB5282/PRJDB5282_Coverage.r plot PRJDB5282

perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE143607 cellranger5/GSE143607/GSE143607.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 fixed_neurons_2000 cellranger5/fixed_neurons_2000/fixed_neurons_2000.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 fixed_neurons_6days_2000 cellranger5/fixed_neurons_6days_2000/fixed_neurons_6days_2000.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 neuron_9k cellranger5/neuron_9k/neuron_9k.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 neurons_2000 cellranger5/neurons_2000/neurons_2000.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 neurons_900 cellranger5/neurons_900/neurons_900.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 nuclei_2k cellranger5/nuclei_2k/nuclei_2k.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 nuclei_900 cellranger5/nuclei_900/nuclei_900.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 pbmc4k cellranger5/pbmc4k/pbmc4k.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 pbmc8k cellranger5/pbmc8k/pbmc8k.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 t_3k cellranger5/t_3k/t_3k.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 t_4k cellranger5/t_4k/t_4k.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 E_MTAB_3929 SkewC_Non10x_datasets/Human_dataset/E-MTAB-3929/E-MTAB-3929_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE64016 SkewC_Non10x_datasets/Human_dataset/GSE64016/GSE64016_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE70151 SkewC_Non10x_datasets/Human_dataset/GSE70151/GSE70151_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE75748 SkewC_Non10x_datasets/Human_dataset/GSE75748/GSE75748_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 PRJEB8994 SkewC_Non10x_datasets/Human_dataset/PRJEB8994/PRJEB8994_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 E_MTAB_2512 SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-2512/E-MTAB-2512_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 E_MTAB_2600 SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-2600/E-MTAB-2600_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 E_MTAB_2805 SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-2805/E-MTAB-2805_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 E_MTAB_3857 SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-3857/E-MTAB-3857_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 E_MTAB_4619 SkewC_Non10x_datasets/Mouse_dataset/E-MTAB-4619/E-MTAB-4619_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE29087 SkewC_Non10x_datasets/Mouse_dataset/GSE29087/GSE29087_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE42268 SkewC_Non10x_datasets/Mouse_dataset/GSE42268/GSE42268_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE45719 SkewC_Non10x_datasets/Mouse_dataset/GSE45719/GSE45719_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE46980 SkewC_Non10x_datasets/Mouse_dataset/GSE46980/GSE46980_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE53386 SkewC_Non10x_datasets/Mouse_dataset/GSE53386/GSE53386_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE54695 SkewC_Non10x_datasets/Mouse_dataset/GSE54695/GSE54695_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE56638 SkewC_Non10x_datasets/Mouse_dataset/GSE56638/GSE56638_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE59114 SkewC_Non10x_datasets/Mouse_dataset/GSE59114/GSE59114_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE67310 SkewC_Non10x_datasets/Mouse_dataset/GSE67310/GSE67310_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE68981 SkewC_Non10x_datasets/Mouse_dataset/GSE68981/GSE68981_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE70657 SkewC_Non10x_datasets/Mouse_dataset/GSE70657/GSE70657_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE74833 SkewC_Non10x_datasets/Mouse_dataset/GSE74833/GSE74833_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE75659 SkewC_Non10x_datasets/Mouse_dataset/GSE75659/GSE75659_Coverage.r plot
perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 GSE98664 SkewC_Non10x_datasets/Mouse_dataset/GSE98664/GSE98664_Coverage.r plot
#perl bin/SkewC.pl -s 0.01 -e 0.3 -d 0.01 PRJDB5282 SkewC_Non10x_datasets/Mouse_dataset/PRJDB5282/PRJDB5282_Coverage.r plot