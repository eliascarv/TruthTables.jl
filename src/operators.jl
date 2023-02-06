(-->)(x::Bool, y::Bool) = !x || y
const (<-->) = (===)
const ∧ = &
const ∨ = |
const ¬ = !
const → = (-->)
const ⇒ = (-->)
const ↔ = (<-->)
const ⇔ = (<-->)

const OPRS = (
  :&, :∧,
  :|, :∨,
  :!, :~, :¬,
  :⊻, :⊼, :⊽,
  :(-->), :→, :⇒,
  :(<-->), :↔, :⇔,
  :(===), :≡
)
