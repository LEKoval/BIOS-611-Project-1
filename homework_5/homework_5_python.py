import pandas as pd
import numpy as np
from sklearn.manifold import TSNE
from plotnine import *


df=pd.read_csv("cleaned_super_stats.csv")

tsne = TSNE(n_components=2, perplexity=5, early_exaggeration=20, learning_rate=100);
projection = pd.DataFrame(tsne.fit_transform(df[["Intelligence","Strength","Speed","Durability","Power","Combat"]]), columns=["P1","P2"])

df["P1"]=projection["P1"]
df["P2"]=projection["P2"]

df.to_csv("superhero_tsne.csv", index=False)

fig=(ggplot(df, aes("P1","P2",color="Alignment")))+geom_point()
fig.save("tsne_viz_py.png")
