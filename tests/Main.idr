import Test.Golden
main: IO ()
main = do
   tests <- testsInDir "." (const True) "tennis rules" [] Nothing
   runner [tests]
