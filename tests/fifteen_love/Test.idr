import Tennis
main: IO ()
main = let (_ ** gameState) = point 0 newGame
       in putStrLn$ gameScore ["A","B"] gameState
