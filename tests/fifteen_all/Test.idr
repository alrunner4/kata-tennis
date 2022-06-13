import Tennis
partial
main: IO ()
main = let (Nothing ** g1) = point 0 newGame
           (_       ** g2) = point 1 g1
       in putStrLn$ gameScore ["A","B"] g2
