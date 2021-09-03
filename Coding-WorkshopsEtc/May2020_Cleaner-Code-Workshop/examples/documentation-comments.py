"""
There is a difference between commenting code and documenting code.

Documentation:
    * Describes what the code does,

    * Is often mirrored both in the code itself as well as in
      some external resource such as a website,

    * Often follows a format that allows for easy/automated 
      construction of that resource/website,

    * Tends to be written at the level of functions, classes, and modules,

    * Is written for future consumers of the code, as well as
      future developers who will modify the code.

Comments:

    * Are only written with future developers in mind, consumers
      and users won't see the comments,

    * Are not used in the creation of an external resource,

    * Tends to be written at the level of individual lines of code,

    * Should be used to explain "why" rather than "what" but,

    * Can be used to explain "what" if the code is difficult to write more clearly.

    * A warning: if someone changes the code without updating the relevant comments
      you end up with a very confusing result where the code does one thing and the
      comments say something else. This is a worst case scenario for comments. 

In python, the preferred form of "documentation" is a docstring.
For a helpful reference on docstrings: https://realpython.com/documenting-python-code/#documenting-your-python-code-base
and https://www.python.org/dev/peps/pep-0257/
"""


"""
The following class is from the Keras open source library as an example of good documentation 
and commenting. The Keras library is licensed using the MIT license, which is included below. 

All of the text and code below this point is licensed under the MIT license, and is NOT subject 
to the public domain dedication that covers the rest of this repository.

The original writing above this point is dedicated to the public domain.

Source: https://github.com/keras-team/keras/blob/master/keras/optimizers.py
Commit hash when snapshotted: 9080613dbc6f0840d7544bccc416121f0864a7fd
"""

class Adagrad(Optimizer):
    """Adagrad optimizer.
    Adagrad is an optimizer with parameter-specific learning rates,
    which are adapted relative to how frequently a parameter gets
    updated during training. The more updates a parameter receives,
    the smaller the learning rate.
    It is recommended to leave the parameters of this optimizer
    at their default values.
    # Arguments
        learning_rate: float >= 0. Initial learning rate.
    # References
        - [Adaptive Subgradient Methods for Online Learning and Stochastic
           Optimization](http://www.jmlr.org/papers/volume12/duchi11a/duchi11a.pdf)
    """

    def __init__(self, learning_rate=0.01, **kwargs):
        self.initial_decay = kwargs.pop('decay', 0.0)
        self.epsilon = kwargs.pop('epsilon', K.epsilon())
        learning_rate = kwargs.pop('lr', learning_rate)
        super(Adagrad, self).__init__(**kwargs)
        with K.name_scope(self.__class__.__name__):
            self.learning_rate = K.variable(learning_rate, name='learning_rate')
            self.decay = K.variable(self.initial_decay, name='decay')
            self.iterations = K.variable(0, dtype='int64', name='iterations')

    @interfaces.legacy_get_updates_support
    @K.symbolic
    def get_updates(self, loss, params):
        grads = self.get_gradients(loss, params)
        shapes = [K.int_shape(p) for p in params]
        accumulators = [K.zeros(shape, name='accumulator_' + str(i))
                        for (i, shape) in enumerate(shapes)]
        self.weights = [self.iterations] + accumulators
        self.updates = [K.update_add(self.iterations, 1)]

        lr = self.learning_rate
        if self.initial_decay > 0:
            lr = lr * (1. / (1. + self.decay * K.cast(self.iterations,
                                                      K.dtype(self.decay))))

        for p, g, a in zip(params, grads, accumulators):
            new_a = a + K.square(g)  # update accumulator
            self.updates.append(K.update(a, new_a))
            new_p = p - lr * g / (K.sqrt(new_a) + self.epsilon)

            # Apply constraints.
            if getattr(p, 'constraint', None) is not None:
                new_p = p.constraint(new_p)

            self.updates.append(K.update(p, new_p))
        return self.updates

    def set_weights(self, weights):
        params = self.weights
        # Override set_weights for backward compatibility of Keras 2.2.4 optimizer
        # since it does not include iteration at head of the weight list. Set
        # iteration to 0.
        if len(params) == len(weights) + 1:
            weights = [np.array(0)] + weights
        super(Adagrad, self).set_weights(weights)

    def get_config(self):
        config = {'learning_rate': float(K.get_value(self.learning_rate)),
                  'decay': float(K.get_value(self.decay)),
                  'epsilon': self.epsilon}
        base_config = super(Adagrad, self).get_config()
        return dict(list(base_config.items()) + list(config.items()))


"""
License: The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""