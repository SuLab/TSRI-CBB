
"""
If a "one liner" starts becoming hard to read or understand,
try breaking it up onto multiple lines for clarity.

This tactic can be helpful for: 
    
    * Breakup up complex boolean equations
    * Breaking up complex math equations
    * Unnesting function calls
    * Spreading out long single function calls
"""

##### Example 1: Boolean Logic & Unnesting Function Calls #####

# Version 1: The nested calls result in a somewhat confusing boolean equation
# This is the programming equivalent of a run on sentence.
if validateUser(getUser(userId)) and hasActiveSession(getUser(userId)):
    pass

# Version 2: We spread the logic across three lines. 
# It's more code, but each lines purpose is crystal clear.
user = getUser(userId)
userIsValid = validateUser(user)
userIsActive = hasActiveSession(user)
if userIsValid and userIsActive:
    pass

# Version 3: We moved the logic into methods of a class. Now
# we only have two lines and our code's purpose is still obvious.
user = User(userId)
if user.isValid() and user.isActive():
    pass


##### Example 2: Long Function Calls #####

# Version 1: Some functions accept a lot of parameters.
# Sometimes the values/names of those parameters are long.
# The result is a really long line that's difficult to read,
# and might require sideways scrolling, which is always annoying.
model.compile(optimizer=keras.optimizers.RMSprop(), loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True), metrics=['sparse_categorical_accuracy'])
history = model.fit(x_train, y_train, batch_size=64, epochs=3, validation_data=(x_val, y_val))

# Version 2: choose short, obfuscating variable names to save space in the 
# function call. This is not really better than version 1 in my opinion.
o = keras.optimizers.RMSprop()
l = keras.losses.SparseCategoricalCrossentropy(from_logits=True), 
m = ['sparse_categorical_accuracy']
bs = 64
e = 3
model.compile(optimizer=o, loss=l, metrics=m)
history = model.fit(x_train, y_train, batch_size=bs, epochs=e, validation_data=(x_val, y_val)

# Version 3: Give each parameter a line, or group one or two tightly coupled parameters on a line.
# Use indentation as a visual clue that this is all one function call. This is much clearer.
model.compile(
    optimizer=keras.optimizers.RMSprop(),
    loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=['sparse_categorical_accuracy']
)
history = model.fit(
    x_train, y_train,
    batch_size=64,
    epochs=3,
    validation_data=(x_val, y_val)
)
