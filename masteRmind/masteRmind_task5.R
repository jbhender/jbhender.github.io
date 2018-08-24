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


############
## Task 4 ##
############

# 12. Standard feedback: -----------------------------------------------------
feedback = function( result, secret, sep = ', ' ) {
  n = length(secret)
  
  if( result$n_exact == n ) {
    win_msg = sprintf(
      '@<##>@ - Congratulations! You guessed the secret code: %s.\n', 
      paste(secret, collapse=sep) )
    cat(win_msg)
    return(TRUE)
    
  } else {
    msg = sprintf('@<##>@: exact = %i, colors = %i.\n', result$n_exact, 
                  result$n_color )
    cat(msg)
  }
  
  return(FALSE)
}

# Tests
feedback( result = list(n_exact = 4, n_colors = 4),
          secret = c('Blue', 'White', 'Yellow', 'Gold')
)

feedback( result = list(n_exact = 2, n_colors = 3),
          secret = c('Blue', 'White', 'Yellow', 'Gold')
)

############
## Task 5 ##
############

# 13. Translate and verify user input: ----------------------------------------
clean_input = function(guess, n = 4, sep = ', ', dict = std_dict) {
  
  # Split guess into a vector
  guess = split_guess(guess, sep = sep)
  
  # Do some error checking
  too_few = FALSE
  if( length(guess) < n ) {
    too_few = TRUE
  }
  
  too_many = FALSE
  if( length(guess) > n ) {
    too_many = TRUE
  }
  
  # Could standardize case first, check for quotes, etc ..
  # Check against dictionary
  not_in_dict = ! { guess %in% dict }
  
  # 14. Check if user provided accepted abbreviations
  for( i in 1:length(guess) ) {
    
    if( not_in_dict[i] ) {
      vals = names(dict) %in% guess[i] 
      
      if( sum(vals) == 1 ) {
        guess[i] = unname( dict[which(vals)]  )
        not_in_dict[i] = FALSE
      } 
    }
  }
  
  list( guess = guess, #cleaned guess
        too_few = too_few, 
        too_many = too_many,
        not_in_dict = not_in_dict,
        error_free = ! any(too_few, too_many, not_in_dict)
  )
}

## Tests
# Too few inputs
clean_input( 'R, Green, Blue', n = 4, sep = ', ', dict = std_dict)

# Too many inputs
clean_input( 'Yellow, R, Green, Blue, Gold', n = 4, sep = ', ', dict = std_dict)

# Bad color
clean_input( 'R, Gr, Bu, Ba, XX')

# (14) Substitute abbreviations
clean_input( 'R, Green, Blue, Gold', n = 4, sep = ', ', dict = std_dict)
clean_input( 'Blue, White, Yellow, Gold')


# Game skeleton: --------------------------------------------------------------
play_mastermind = function(n, dict, max_turns = 10, repeats = FALSE, sep = ', ') 
{
  # Initialize
  turn = 1
  win = FALSE
  secret = gen_code(n, dict, repeats)
  
  # Gameplay 
  while( turn <= max_turns && !win ) {
    guess = request_input(turn)
    
    input = clean_input(guess, n, sep, dict)
    
    if( input$error_free ) {
      result = check_code(input$guess, secret)
      
      win = feedback( result, secret )
      
      turn = turn + 1
    } else {
      print_error(input, n, sep)
      cat('@<##>@ - Please guess again:\n')
    }
  }
  
  # Return with win
  if( win ) return( invisible(1) )
  
  if( turn > max_turns ){
    lose_msg = sprintf('@<##>@ - Mastermind wins! The secret code was:\n %s.\n\n', 
                       paste( secret, collapse=sep))
    cat(lose_msg)
  }
  
  # Return with loss
  return(invisible(0))
}

## Tests

# Test a winning solution
set.seed(1)
play_mastermind(2, std_dict, 2)
#Blue, White

# Test a losing solution
set.seed(2)
play_mastermind(2, std_dict, 2)
#Blue, Red
#Green, Yellow
