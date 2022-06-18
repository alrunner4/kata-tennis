import Tennis.State

data TestFailureMode
   = UnexpectedScore String String
   | UnexpectedPoint Player

showFailure: Vect 2 String -> TestFailureMode -> String
showFailure players = \case
   UnexpectedScore expected tested
      => "expected score: \{expected}\ntested score: \{tested}\n"
   UnexpectedPoint p
      => "illegal point scored after \{index p players} won\n"

[MonadErrorAdapter] {construct: e -> e'} -> {deconstruct: e' -> Maybe e} -> MonadError e' m =>
   MonadError e m where
      throwError = throwError . construct
      catchError act handle = tryError act >>= \case
         Right x => pure x
         Left e' => case deconstruct e' of
            Just e  => handle e
            Nothing => throwError e'

main: IO ()
main = do

   let players: Vect 2 String
       players = ["A","B"]

   let assert_score: MonadState AnyState m => MonadError TestFailureMode m => String -> m ()
       assert_score expected = do
         let tested = gameScore players (snd !get)
         when (expected /= tested)$
            throwError (UnexpectedScore expected tested)

   let playerErrorAdapter = MonadErrorAdapter {
      construct = UnexpectedPoint     ,
      deconstruct = \case
         UnexpectedPoint p => Just p
         _                 => Nothing }

   eitherT
      (\p => putStr "error: \{showFailure players p}\n")
      (\_ => putStr "tests passed\n")
    $ evalStateT {stateType = AnyState} (_ ** love_all)$ do
         assert_score "love all"
         State.point 0
         assert_score "fifteen, love"
         State.point 1
         assert_score "fifteen all"
         State.point 0
         assert_score "thirty, fifteen"

