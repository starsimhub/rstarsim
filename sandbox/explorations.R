# Explore Reticulate and Starsim

library('reticulate')
ss <- import('starsim')
sim = ss$Sim(diseases='sis', networks='random')
sim$run()
df <- sim$to_df()
print(df)
# sim$plot() # <- does not work
