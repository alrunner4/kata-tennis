import Tennis
partial
main: IO ()
main = let (Nothing ** g1) = point L newGameState
           (_       ** g2) = point R g1
       in putStrLn (gameScore g2)
