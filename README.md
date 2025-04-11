# Predicting US Election Turnout 
This repository houses a project that compares the applicability of different Neural Network infrastructures in predicting Voter Turnout in American General Elections.

# Overview
My idea revolved around the question voter turnout in US presidential elections, and specifically _how_ we can explore the fact that these elections occur every 4 years (cyclical!). This led to me asking the question _"Does the characterization of voting data as time-series data improve our predictive ability for Voter Turnout?"_. In order to answer this question, I came up with a research design that pitted a Recurrent Neural Network (RNN) against a Feed-Forward Network (FFN) to see whether the there would be added predictive value in understanding voting data as having some sort of temporal inter-dependency vs. the more common cross-sectional approach.

# Data
To find these answers, I took voting data from the MIT Elections Data + Science Lab on [County Presidential Returns from 2000-2020](https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ), paired with data from the US Census Bureau's [American Community Survey](https://www.census.gov/programs-surveys/acs/news/data-releases.2020.html#list-tab-1133175109), which I accessed using the [Census Bureau's API](https://www.census.gov/data/developers/guidance/api-user-guide.html). After fetching and cleaning the data I ended up with ~250 variables from the Census and joined it to the MIT Voter Turnout data for the years 2008, 2012, 2016, and 2020.
<img width="944" alt="Data" src="https://github.com/user-attachments/assets/3e6e7b9c-33cd-403c-8fb9-9af8a96a40e7">


# Implementation
From there, the challenge was to experiment with FFN and RRN architectures in order to find some answers!
You can find the code I used for preparing and running these models in Google Colab: 
[Link for FFN Notebook](https://colab.research.google.com/drive/1lBo-yzkQqPD3JSVew7IEFT0s1UpEKBOs?usp=sharing)
[Link for RNN Notebook](https://colab.research.google.com/drive/13BGCNjAV9J78n9Pnj1JM-5LDNr65RenT?usp=sharing)
Some code highlights are shown below.
<img width="945" alt="Two Pipelines" src="https://github.com/user-attachments/assets/c995381c-6883-41af-8ea3-5e835c22fd09">


# FFN
The FFN ended up requiring quite a few anti-overfitting measures given the small dataset (10,000 observations), but in the end it performed very well. These efforts against overfitting included a very small (slow) Learning Rate, LeakyReLu as an activation function, L2 (Ridge) Regularization, and a Dropout Layer.

```
eta = 0.0001 # Learning rate

model = Sequential([ # Define the FFN model architecture
    Dense(128, input_shape=(X_train.shape[1],), activation='leaky_relu'),  # First hidden layer
    Dense(64, activation='leaky_relu',kernel_regularizer=regularizers.l2(0.01)),                                    # Second hidden layer
    Dropout(0.2),                                                                                                  # Dropout layer
    Dense(32, activation='leaky_relu'),                                    # Third hidden layer
    Dense(1, activation='sigmoid')                                    # change from linear to sigmoid
])

model.compile(optimizer=Adam(learning_rate= eta), # Compile the model with learning rate
              loss='mean_squared_error', # loss function MSE
              metrics=['mae']) # and added metric MAE

model.summary() # View the model summary and architecture
```





# RNN
While the RNN did not have overfitting issues in the same way that the FFN did, there was an inherent challenge in the data availability for training a sequence-based model. As I only had access to data from 2008, 2012, 2016, and 2020, I had to use 2008-2016 as time-series training data and 2020 as validation, meaning that the model didn't get much chance to learn!  While the results are encouraging, and they show that the existing architectures of FFN and RNN are both very capable at prediction this task, there seems to be insufficient clarity on whether the original hypothesis (of formulating Voter Turnout as temporally dependent on its previous states) is proven or disproven by the results of this study.


```
eta = 0.0005 # Learning rate

model = Sequential() # RNN, sequential data

model.add(SimpleRNN(units=64, activation='leaky_relu', # Adding a SimpleRNN layer with leaky ReLu
                    kernel_regularizer=l2(0.01),  # Regularizes the kernel weights
                    recurrent_regularizer=l2(0.01),  # Regularizes recurrent connections
                    input_shape=(X_train.shape[1], X_train.shape[2]))) # Inputs
model.add(Dropout(0.1))  # Dropout to prevent overfitting
model.add(Dense(1, # Adding a Dense layer to output the prediction
                    activation='sigmoid'))  # Sigmoid activation for output later ensures output is bounded to [0, 1]

model.compile(optimizer=Adam(learning_rate=eta), # Compile the model
              loss='mean_squared_error', # Typical loss function, MSE
              metrics=['mae']) # MAE as our second metric instead of accuracy, since we are doing regression

model.summary() # View the model summary and architecture
```


# Comparison
In the end, we find that the FFN performs better than the RNN, though it is largely explained by the unavailability of many time periods in the data (which would benefit the RNN). Both models achieve Prediction Error around ~0.03, which tells us that their predictions of Voter Turnout tend to be only about 3 percentage points away from the true value. Not bad! 
<img width="947" alt="RNNFFNCOMPARE" src="https://github.com/user-attachments/assets/026cf8cb-555a-43b1-af44-49a4e8c1a2e6">

# Next Steps
To achieve a full refutation or confirmation of the central question of temporal dependency, future research would need to acquire more years of data, allowing for a proper time-series formulation. Additionally, a return to 'the drawing board' in terms of variables of interest, determinants of Turnout, and ontological questions would need to be further scrutinized. Neural Networks are very powerful, and this implementation is only a very modest example of their power-- macro indicators such as unemployment and inflation or demographic data with higher frequency could certainly help in this regard. Finally, more stringent decisions on the treatment of outliers could be explored, given that both models struggled with a few of these, as shown below in the FFN's predictions.
<img width="865" alt="FFNPredictions" src="https://github.com/user-attachments/assets/92c8f59b-0a12-45f3-ba39-4c940adf91e3">

