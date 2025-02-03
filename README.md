## Noir Map

Implementation of map using key sorted linked list.

--- 

### Usage

```rust
let mut some_map: Map<u64, Field, 12> = Map::new();
some_map.insert(76, 2098);
some_map.insert(12, 527);
assert(some_map.len == 2);

let value = some_map.remove(76);
assert(value.is_some());
assert(value.unwrap() == 2098);
```

---

### Benchmarks

#### Noir standard library's HashMap

| Methods | Number of Gates |
| ------- | --------------- |
insert | 4671
remove | 9837
get | 5388

#### Map (This implementation)

| Methods | Number of Gates |
| ------- | --------------- |
insert | 24 (~195x)
removal | 255 (~39x)
get | 34 (~159x)

## Limitations

`Field` type cannot be key as the key involves `ParitalOrd` and `PartialEq` which is not possible for `Field`.