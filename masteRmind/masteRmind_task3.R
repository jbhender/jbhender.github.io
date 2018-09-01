# Functional code base for masteRmind game in preparation for 
# R programming workshop to take place August 24, 2018.
#
# Updated: August 23, 2018 
# Author: James Henderson (jbhender@umich.edu)

############
## Task 1 ##
############

# Create a dictionary of eight colors: ---------------------------------------
std_dict = c( R='Red', Gr='Green', Bu='Blue', Y='Yellow',
              Go='Gold', O='Orange', Ba='Black', W='White' )

############
## Task 2 ##
############

# 6. Generate the secret code: ------------------------------------------------
# n - the number of words in the secret code
# dict - a dictionary from which to choose the code. 
# repeats = FALSE, - should repeats be allowed?
# sep - how to separate words in the code
# based on the R function "sample"

gen_code = function(n, dict, repeats=FALSE) {
  sample(dict, n, replace = repeats)
}

# Test that it works
gen_code(4, std_dict)


# 7. Recieve user input: ---------------------------------------------------------
request_input = function() {
  
  # Prompt user
  request_str = 'Plase enter guess:\n'
  cat(request_str)
  
  # Get input
  guess = readline()
  
  # Return input
  guess
}

# Test
x = request_input() 
Blue, Orange, Green, Red
x

# 8 / 9. Recieve user input and modify prompt: --------------------------------
request_input = function(num_guess = 1) {
  
  # Prompt user
  request_str = sprintf('Plase enter guess #%i:\n', num_guess)
  cat(request_str)
  
  # Get input
  guess = readline()
  
  # Return input
  guess
}

# Test
x = request_input(2) 
Blue, Orange, Green, Red
x

# 10. We'll use the safer base R version: -------------------------------------
split_guess = function(guess, sep = ', '){
  strsplit(guess, split = sep, fixed = TRUE)[[1]]
}

# Test
split_guess(x)

############
## Task 3 ##
############

# 11. Compare a guessed code to the master code: ------------------------------
check_code = function(guess, secret, n = 4) {
  
  n_exact = sum( guess == secret )
  n_color = length( intersect(guess, secret) )
  
  list( n_exact = n_exact, n_color = n_color )
}

# Tests
#check_code( paste(gen_code(), collapse=', ' ), secret = gen_code() )
check_code( c('Blue', 'Orange', 'Red', 'Yellow'),
            secret = c('Blue', 'Yellow', 'Gold', 'Green'))



