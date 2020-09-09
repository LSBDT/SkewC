example.TTTGTCATCTAACGGT_1 <- c(0.625,0.736413043478261,0.823369565217391,0.891304347826087,0.994565217391304,1,0.970108695652174,0.956521739130435,0.96195652173913,0.945652173913043,0.89945652173913,0.880434782608696,0.817934782608696,0.83695652173913,0.820652173913043,0.815217391304348,0.83695652173913,0.730978260869565,0.58695652173913,0.546195652173913,0.519021739130435,0.497282608695652,0.491847826086957,0.4375,0.404891304347826,0.375,0.3125,0.317934782608696,0.309782608695652,0.290760869565217,0.28804347826087,0.304347826086957,0.271739130434783,0.296195652173913,0.307065217391304,0.296195652173913,0.28804347826087,0.27445652173913,0.255434782608696,0.285326086956522,0.277173913043478,0.241847826086957,0.279891304347826,0.27445652173913,0.233695652173913,0.230978260869565,0.255434782608696,0.241847826086957,0.260869565217391,0.22554347826087,0.195652173913043,0.171195652173913,0.16304347826087,0.160326086956522,0.168478260869565,0.16304347826087,0.165760869565217,0.168478260869565,0.160326086956522,0.1875,0.14945652173913,0.144021739130435,0.146739130434783,0.127717391304348,0.160326086956522,0.171195652173913,0.168478260869565,0.160326086956522,0.157608695652174,0.141304347826087,0.127717391304348,0.122282608695652,0.127717391304348,0.114130434782609,0.114130434782609,0.119565217391304,0.133152173913043,0.078804347826087,0.0597826086956522,0.0353260869565217,0.0380434782608696,0.0326086956521739,0.0353260869565217,0.00815217391304348,0.016304347826087,0.0271739130434783,0.0407608695652174,0.00543478260869565,0.0135869565217391,0.0135869565217391,0,0.0298913043478261,0.0353260869565217,0.0190217391304348,0.0271739130434783,0.0298913043478261,0,0.0108695652173913,0.0135869565217391,0.0108695652173913)


pdf("coverage/example.TTTGTCATCTAACGGT-1.geneBodyCoverage.curves.pdf")
x=1:100
icolor = colorRampPalette(c("#7fc97f","#beaed4","#fdc086","#ffff99","#386cb0","#f0027f"))(1)
plot(x,example.TTTGTCATCTAACGGT_1,type='l',xlab="Gene body percentile (5'->3')", ylab="Coverage",lwd=0.8,col=icolor[1])
dev.off()
