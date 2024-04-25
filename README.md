## Noir Map

Implementation of map key sorted using linked list.

### Usage

```rust
let mut some_map: Map<u64, Field, 12> = Map::default();
some_map.insert(76, 2098);
some_map.insert(12, 527);
assert(some_map.len == 2);

let value = some_map.remove(76);
assert(value.is_some());
assert(value.unwrap() == 2098);
```

### Methods

#### Map::insert
Inserts a key, value pair in $O(1)$ constraint. If key exists, inserts the new value, and returns the old value. Lookups are unconstrained. But, still insert is not underconstrained.

#### Map::remove
Removes a key, value pair in $O(1)$ constraint. It returns the value if key exists. Lookups are unconstrained. But, still insert is not underconstrained.

#### Map::len
Returns the number of entries in the map.

#### Map::is_empty
Checks if the map is empty.

#### Map::contains_key
Checks if the given key exists in the map.

#### Map::get
Returns the value of the corresponding key.

#### Map::at
Returns the item of the corrsponding key.

#### Map::keys
Returns all the keys in the map.

#### Map::values
Returns all the values in the map.

#### Map::default
Creates an instance of the map.

### Benchmarks

This is measured after 3 insertions. 

#### Noir standard library's HashMap

| Methods | Number of Gates |
| ------- | --------------- |
insert | 46151
remove | 47995
get | 5234

### Map (This implementation)

| Methods | Number of Gates |
| ------- | --------------- |
insert | 7998 (5.77x)
removal |  16302 (2.94x)
get | 4085 (1.28x)