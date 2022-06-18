module Tennis.State

import public Control.Monad.Either
import public Control.Monad.State
import public Tennis

public export
point: Player -> MonadError Player m => MonadState AnyState m => m ()
point p = do
   (Nothing ** s) <- get | (Just winner ** _) => throwError winner
   put (Tennis.point p s)

public export
winner: MonadState AnyState m => m (Maybe Player)
winner = get <&> fst
