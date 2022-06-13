module Tennis

import public Data.Fin
import public Data.Vect

%default total

public export
Player: Type
Player = Fin 2

mutual

   public export
   PlayingState: Type
   PlayingState = GameState {winner = Nothing}

   public export
   WinnerState: Player -> Type
   WinnerState p = GameState {winner = Just p}

   export
   data GameState: {winner: Maybe Player} -> Type where
      ||| Due to the simplicity of using `weaken` on `Fin` to represent scoring, `Scores` encodes
      ||| player scores with `FZ` as maximum rather than minimum.
      Scores: Fin 4 -> Fin 4 -> PlayingState
      Advantage:     Player  -> PlayingState
      Winner:    (p: Player) -> WinnerState p

public export
AnyState: Type
AnyState = (winner ** GameState {winner})

export
deuce: PlayingState
deuce = Scores FZ FZ

export
isDeuce: PlayingState -> Bool
isDeuce( Scores FZ FZ ) = True
isDeuce _ = False

export
newGame: PlayingState
newGame = Scores last last

score: Fin 4 -> String
score 3 = "love"
score 2 = "fifteen"
score 1 = "thirty"
score 0 = "forty"

public export
gameScore: Vect 2 String -> GameState -> String
gameScore playerNames = \case
   s@(Scores l r) =>
      if isDeuce s then "deuce"
      else score l ++ if l == r then " all"
                                else ", " ++ score r
   Advantage p => "advantage " ++ index p playerNames
   Winner p    => "winner "    ++ index p playerNames

public export
point: Player -> PlayingState -> AnyState
point p (Advantage q) = if p == q then (_ ** Winner p) else (_ ** deuce)
point p (Scores  FZ    FZ   ) = (_ ** Advantage p)
point 0 (Scores  FZ    _    ) = (_ ** Winner 0)
point 1 (Scores  _     FZ   ) = (_ ** Winner 1)
point 0 (Scores (FS l)    r ) = (_ ** Scores (weaken l) r)
point 1 (Scores     l (FS r)) = (_ ** Scores l (weaken r))

||| If the sequence of points given is a legal continuation of the input state, computes the final
||| state, otherwise produces Nothing.
public export
runGame: List Player -> PlayingState -> Maybe AnyState
runGame [] s = Just (_ ** s)
runGame (p::ps) s = case point p s of
   (Nothing ** s') => runGame ps s'
   s' => case ps of
      [] => Just s'
      _  => Nothing
