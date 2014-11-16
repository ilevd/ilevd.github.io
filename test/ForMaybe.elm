module ForMaybe where

import Maybe (isJust)
-- Shorthand map over List-like


f <$ lx = map f lx                        -- <$> in Haskell
lx $> f = map f lx
infixr 2 <$
infixr 2 $>
 
-- Shorthand sequential application 
lf <$$ lx = zipWith (\f x -> f x) lf lx   -- <*> in Haskell
lx $$> lf = zipWith (\f x -> f x) lf lx   -- <**> in Haskell
infixr 1 <$$
infixr 1 $$>
 
--Shorthand map over Maybe
f <? mx = case mx of                      -- <$> in Haskell
  (Just x) -> Just (f x)
  Nothing  -> Nothing
mx ?> f = case mx of 
  Just x  -> Just (f x)
  Nothing -> Nothing
infixr 2 <?
infixr 2 ?>
 
-- Shorthand sequential application
mf <?? mx = if isJust mx && isJust mf     -- <*> in Haskell
              then Just <| (\(Just f) (Just x) -> f x) mf mx
              else Nothing
mx ??> mf = if isJust mx && isJust mf     -- <**> in Haskell
              then Just <| (\(Just f) (Just x) -> f x) mf mx
              else Nothing
infixr 1 <??
infixr 1 ??>