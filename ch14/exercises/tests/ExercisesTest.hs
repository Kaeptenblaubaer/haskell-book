module ExercisesTest where

import           Exercises       (Fool (..), Pool (..), capitalizeWord, half,
                                  reverse, sort)
import           Test.Hspec
import           Test.QuickCheck

prop_halfIdentity :: Double -> Bool
prop_halfIdentity x = halfIdentity x == x
  where
    halfIdentity = (* 2) . half

prop_listOrderedInt :: [Int] -> Bool
prop_listOrderedInt as = listOrdered $ sort as

prop_listOrderedString :: [String] -> Bool
prop_listOrderedString as = listOrdered $ sort as

listOrdered :: (Ord a) => [a] -> Bool
listOrdered xs = snd $ foldr go (Nothing, True) xs
  where
    go _ status@(_, False) = status
    go y (Nothing, t)      = (Just y, t)
    go y (Just x, t)       = (Just y, x >= y)

prop_plusAssociativeInt :: (Int, Int, Int) -> Bool
prop_plusAssociativeInt (x, y, z) = x + (y + z) == (x + y) + z

prop_plusCommutativeInt :: (Int, Int) -> Bool
prop_plusCommutativeInt (x, y) = x + y == y + x

prop_timesAssociativeInt :: (Int, Int, Int) -> Bool
prop_timesAssociativeInt (x, y, z) = x * (y * z) == (x * y) * z

prop_timesCommutativeInt :: (Int, Int) -> Bool
prop_timesCommutativeInt (x, y) = x * y == y * x

prop_quotRemInt :: (Int, NonZero Int) -> Bool
prop_quotRemInt (x, NonZero y) = (quot x y) * y + (rem x y) == x

prop_divModInt :: (Int, NonZero Int) -> Bool
prop_divModInt (x, NonZero y) = (div x y) * y + (mod x y) == x

-- False
prop_powerAssociativeInt :: (Int, Int, Int) -> Bool
prop_powerAssociativeInt (x, y, z) = x ^ (y ^ z) == (x ^ y) ^ z

-- False
prop_powerCommutativeInt :: (Int, Int) -> Bool
prop_powerCommutativeInt (x, y) = x ^ y == y ^ x

prop_reverseIdentityInt :: [Int] -> Bool
prop_reverseIdentityInt as = reverseIdentity as == as

prop_reverseIdentityString :: [String] -> Bool
prop_reverseIdentityString as = reverseIdentity as == as

reverseIdentity :: [a] -> [a]
reverseIdentity = reverse . reverse

prop_dollarStringInt :: (Fun String Int, String) -> Bool
prop_dollarStringInt (Fun _ f, s) = f s == (f $ s)

prop_dotStringIntString :: (Fun Int String, Fun String Int, String) -> Bool
prop_dotStringIntString (Fun _ f, Fun _ g, s) = (f . g $ s) == f (g s)

prop_foldrAppendString :: (String, String) -> Bool
prop_foldrAppendString (a, b) = foldr (:) a b == (flip (++)) a b

prop_foldrConcatString :: [String] -> Bool
prop_foldrConcatString as = foldr (++) [] as == concat as

-- False for n < 0, and for lists with less than n elemenets
prop_isThatSo :: (Int, [String]) -> Bool
prop_isThatSo (n, xs) = length (take n xs) == n

prop_readShowIdentityString :: String -> Bool
prop_readShowIdentityString s = s == read (show s)

prop_readShowIdentityIntList :: [Int] -> Bool
prop_readShowIdentityIntList s = s == read (show s)

-- False for numbers whose square root cannot be represented exactly with an IEEE-754 floating point number
prop_squareIdentity :: NonZero Float -> Bool
prop_squareIdentity (NonZero x) = x == (square . sqrt $ x)
  where
    square x = x * x

twice :: (b -> b) -> b -> b
twice f = f . f

fourTimes :: (b -> b) -> b -> b
fourTimes = twice . twice

prop_capitalizeWordIdempotent :: String -> Bool
prop_capitalizeWordIdempotent x =
  (capitalizeWord x == twice capitalizeWord x) &&
  (capitalizeWord x == fourTimes capitalizeWord x)

prop_sortIdempotentString :: [String] -> Bool
prop_sortIdempotentString x =
  (sort x == twice sort x) && (sort x == fourTimes sort x)

genFool :: Gen Fool
genFool = oneof [return Frue, return Fulse]

genPool :: Gen Pool
genPool = frequency [(1, return Prue), (2, return Pulse)]

main :: IO ()
main =
  hspec $ do
    describe "half" $ do
      it "half times two equals identity" $ property prop_halfIdentity
    describe "sort" $ do
      it "orders a list of Ints" $ property prop_listOrderedInt
      it "orders a list of Strings" $ property prop_listOrderedString
      it "is idempotent for a list of Strings" $
        property prop_sortIdempotentString
    describe "plus" $ do
      it "associates with Ints" $ property prop_plusAssociativeInt
      it "commutes with Ints" $ property prop_plusCommutativeInt
    describe "times" $ do
      it "associates with Ints" $ property prop_timesAssociativeInt
      it "commutes with Ints" $ property prop_timesCommutativeInt
    describe "quot/rem" $ do it "quot * y + rem = x" $ property prop_quotRemInt
    describe "div/mod" $ do it "div * y + mod = x" $ property prop_divModInt
    -- describe "power" $ do
    --   it "associates with Ints" $ property prop_powerAssociativeInt
    --   it "commutes with Ints" $ property prop_powerCommutativeInt
    describe "reverse" $ do
      it "reversing the reverse equals identity with Ints" $
        property prop_reverseIdentityInt
      it "reversing the reverse equals identity with Strings" $
        property prop_reverseIdentityString
    describe "dollar sign" $ do
      it "applies a String argument to a String -> Int function" $
        property prop_dollarStringInt
    describe "dot" $ do
      it "composes functions (String -> Int, Int -> String)" $
        property prop_dollarStringInt
    describe "foldr (:)" $ do
      it "equals flip (++)" $ property prop_foldrAppendString
    describe "foldr (++) []" $ do
      it "equals concat" $ property prop_foldrConcatString
    -- describe "length (take n xs)" $ do it "equals n" $ property prop_isThatSo
    describe "read . show" $ do
      it "equals identity for String" $ property prop_readShowIdentityString
      it "equals identity for [Int]" $ property prop_readShowIdentityIntList
    -- describe "square . sqrt" $ do
    --   it "equals identity for non-zero Float" $ property prop_squareIdentity
    describe "capitalizeWord" $ do
      it "is idempotent" $ property prop_capitalizeWordIdempotent
