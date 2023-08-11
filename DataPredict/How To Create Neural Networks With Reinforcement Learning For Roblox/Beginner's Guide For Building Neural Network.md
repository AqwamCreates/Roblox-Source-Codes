# Beginner's Guide For Building Neural Networks

This guide assumes that you have basic understanding of neural networks. If not, you can find the resources online and have a look at how neural networks works.

Without further ado, let's begin.

## Layers

The choice of your layers are quite important. It is one of the factor determine the accuracy and the training speed of your neural network model.

Usually, it is recommended that you have few layers if you can determine what pattern leads to certain predictions. For example:

* Four classes for four different combination of inputs, where each combination belongs to one class. In other words, two inputs and four outputs.

*  Two classes for two different combinations of inputs. If the input is greater than 0, then it belongs to class 1, otherwise class -1.

If you can determine the pattern, then I recommend you that you only build two layer neural network.

## Activation functions

Different activation functions have different properties. It is very important to choose the correct ones to achieve high accuracy. Here are the functions with their properties listed below:

* ReLU: Great for making sure only few neurons get activated. Terrible at handling large frequency of negative values; it could lead to no neurons activating and lead to innacurate predictions.

* LeakyReLU: Same as ReLU, but less terrible at handling negative values.

* ELU: Same as ReLU, but capable of handling negative values. The only problem is the computational cost as it uses exponent.

* Sigmoid: As values goes further from 0.5, the output slowly reaches 1 or 0; excellent for making sure no large outputs being passed on to next neuron. But being not centered around 0 may cause some issue with some optimizers and weight initialization strategies.

* Tanh: Same as sigmoid, but it is centered around 0. So less issues with optimizers and some initialization strategies.



## Bias Neuron.

The presence of bias neuron must not be underestimated. It allows the calculated values to move away from 0 instead of being centered to it.
