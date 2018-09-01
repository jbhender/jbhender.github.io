# Functional code base for masteRmind game in preparation for 
# R programming workshop to take place August 24, 2018.
#
# Updated: August 23, 2018 
# Author: James Henderson (jbhender@umich.edu)

# Create a dictionary of eight colors: ---------------------------------------
std_dict = c( R='Red', Gr='Green', Bu='Blue', Y='Yellow',
              Go='Gold', O='Orange', Ba='Black', W='White' )

# Generate the secret code: ---------------------------------------------------
# n - the number of words in the secret code
# dict - a dictionary from which to choose the code. 
# If NULL the standard dictionary is used.
# repeats = FALSE, - should repeats be allowed?
# based on the R function "sample"
# sep - how to separate words in the code

gen_code = function(n, dict=NULL, repeats=FALSE) {
  if( is.null(dict) ) {
    dict = c( R='Red', Gr='Green', Bu='Blue', Y='Yellow',
              Go='Gold', O='Orange', Ba='Black', W='White' )
  }
  
  #paste( sample(dict, n, replace = repeats), collapse = sep)
  sample(dict, n, replace = repeats)
}

# Test
gen_code(4, std_dict)

# Recieve user input: ---------------------------------------------------------
request_input = function(num_guess = 1) {
  
  # Prompt user
  request_str = sprintf('Plase enter guess #%i:\n', num_guess)
  cat(request_str)
  
  # Request input
  guess = readline()
  
  # Return input
  guess
}

x = request_input() 
Blue, Orange, Green, Red
x

# Split a user input guess into pieces: --------------------------------------- 
split_guess = function(guess, sep = ', '){
  stringr::str_split(guess, pattern = sep)[[1]]
}
#split_guess( paste(gen_code(4), collapse=', ') )

# Compare a guessed code to the master code: ----------------------------------
check_code = function(guess, secret, n = 4, sep = ', ') {
  
  n_exact = sum( guess == secret )
  n_color = length( intersect(guess, secret) )
  
  list( n_exact = n_exact, n_color = n_color )
}

# Tests
#check_code( paste(gen_code(), collapse=', ' ), secret = gen_code() )
check_code( c('Blue', 'Orange', 'Red', 'Yellow'),
            secret = c('Blue', 'Yellow', 'Gold', 'Green'))


# Standard feedback: ---------------------------------------------------------
feedback = function( guesses, results, secret, n, sep=', ') {
  turn = length(guesses)
  
  if( results[[turn]]$n_exact == n ) {
    win_msg = sprintf('@<##>@ - Congratulations! You guessed the secret code: %s.\n', 
                      paste(secret, collapse=sep))
    cat(win_msg)
    return(TRUE)
  } else {
    
    for(i in 1:turn) {
      msg = sprintf('%i - %s: exact = %i, colors = %i.\n', i, guesses[[i]], 
                    results[[i]]$n_exact, results[[i]]$n_color )
      cat(msg)
    }
    
    return(FALSE)
  }
}
feedback( guesses = list( c('Blue, White, Yellow, Gold') ),
          results = list( list(n_exact = 4, n_colors = 4) ),
          secret = c('Blue', 'White', 'Yellow', 'Gold'),
          n = 4)

# Translate and verify user input: --------------------------------------------
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
  
  # Check if user provided accepted abbreviations
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

# Too few inputs
clean_input( 'R, Green, Blue', n = 4, sep = ', ', dict = std_dict)

# Too many inputs
clean_input( 'Yellow, R, Green, Blue, Gold', n = 4, sep = ', ', dict = std_dict)

# Bad color
clean_input( 'R, Gr, Bu, Ba, XX')

# Substitute abbreviations
clean_input( 'R, Green, Blue, Gold', n = 4, sep = ', ', dict = std_dict)
clean_input( 'Blue, White, Yellow, Gold')



# Response to input error: ----------------------------------------------------
print_error = function(input, n, sep = ', '){
  if( input$error_free ){
    cat('Why did this get called! Programmer error.\n')
  } else {

    # Too few
    if( input$too_few ) {
      err_few = sprintf(
        "Too few elements in guess! Please try again with %i elements separated by '%s'.\n", n, sep )
      cat(err_few)
    }
    
    # Too many
    if( input$too_many ) {
      err_many = sprintf(
        "Too many elements in guess! Please try again with %i elements separated by '%s'.\n", 
        n, sep )
      cat(err_many)
    }
    
  }
}

# Test
print_error( 
  clean_input( 'Yellow, R, Green, Blue, Gold', n = 4, sep = ', ', dict = std_dict),
  4, sep = ', ')


# Standard feedback: ---------------------------------------------------------
feedback = function( guesses, results, secret, n, sep=', ') {
  turn = length(guesses)
  
  if( results[[turn]]$n_exact == n ) {
    win_msg = sprintf('@<##>@ - Congratulations! You guessed the secret code: %s.\n', 
                      paste(secret, collapse=sep))
    cat(win_msg)
    return(TRUE)
  } else {
    
    for(i in 1:turn) {
      msg = sprintf('%i - %s: exact = %i, colors = %i.\n', i, guesses[[i]], 
                    results[[i]]$n_exact, results[[i]]$n_color )
      cat(msg)
    }
    
    return(FALSE)
  }
}
feedback( guesses = list( c('Blue, White, Yellow, Gold') ),
          results = list( list(n_exact = 4, n_colors = 4) ),
          secret = c('Blue', 'White', 'Yellow', 'Gold'),
          n = 4)

# Start up message: ----------------------------------------------------------
start_msg = function(n, dict, max_turns){
  msg = sprintf("@<##>@ - Guess my secret code using %i of the following colors: %s.\n",
                n, paste(dict, collapse = sep))
  cat(msg)
  
  msg = sprintf('@<##>@ - You win if you unlock the vault in less than %i guesses.\n', 
                max_turns)
  cat(msg)
}
# test
start_msg(n, std_dict, 10)

# Game skeleton: --------------------------------------------------------------
play_mastermind = function(n = 4, dict = NULL, max_turns = 10, repeats = FALSE,
                           sep = ', ') 
{
  # Initialize
  quit = FALSE
  turn = 1
  win = FALSE
  secret = gen_code(n, dict, repeats)

  # Storage
  guesses = results = list()

  # Start message
  start_msg(n, dict, max_turns)
  
  # 
  while( turn <= max_turns && !win ) {
     guess = request_input(turn)
     
     if( guess == 'q' ){
       quit = TRUE
       break
     }
     
     input = clean_input(guess, n, sep, dict)
     
     if( input$error_free ) {
       guesses[[turn]] = paste( input$guess, collapse = sep)
       
       results[[turn]] = check_code(input$guess, secret)

       win = feedback(guesses, results, secret, n, sep)
       
       turn = turn + 1
     } else {
       print_error(input, n, sep)
       cat('@<##>@ - Please guess again or type "q" to quit:\n')
     }
  }
  
  # Return with win
  if( win ) return( invisible(1) )
  
  if( turn > max_turns | quit){
    lose_msg = sprintf('@<##>@ - Mastermind wins! The secret code was:\n %s.\n\n', 
                       paste( secret, collapse=sep))
    cat(lose_msg)
  }
  
  # Return with loss
  return(invisible(0))
}

## Tests
set.seed(1)
play_mastermind(4, std_dict)
Blue, White, Yellow, Gold

play_mastermind(4, std_dict)
q


