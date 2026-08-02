# Stable smoke test — assert on the contract (exit code, version shape,
# computed result), never on help/version prose. fish reworks its banner
# and help text freely; the version digits and the `math`/`string` builtins
# are the contract. Branch on the typed platform constant so the script is
# portable across linux/darwin (no windows asset upstream, but keep the
# constant).
FISH = "fish.exe" if ocx.target_platform.os == ocx.os.Windows else "fish"

# fish reads ~/.config/fish/config.fish on every -c invocation. Point HOME and
# the XDG roots at the scratch sandbox so a developer's own config can never
# alter what these assertions see — and so the run stays hermetic on a CI
# runner that has a fish config for some other reason. PATH is a reserved key
# the overlay may not touch, so command resolution is unaffected.
CLEAN = {
    "HOME": ocx.scratch_root,
    "XDG_CONFIG_HOME": ocx.scratch_root,
    "XDG_DATA_HOME": ocx.scratch_root,
}

# Tier 1 + 2: liveness + version SHAPE.
# `fish --version` prints e.g. "fish, version 4.8.1" — match the digits only.
r_version = ocx.run(FISH, "--version", env = CLEAN)
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 3: functional behavior — fish's built-in `math` evaluates an expression
# and command substitution feeds it to `echo`. Assert the computed value, not
# prose: a broken build cannot answer 4 by accident.
r_math = ocx.run(FISH, "-c", "echo (math 2 + 2)", env = CLEAN)
expect.ok(r_math)
expect.contains(r_math.stdout, "4")

# Tier 3 (b): the `string` builtin — the other half of fish's scripting
# surface, and a case transform whose output token cannot appear in the input.
r_string = ocx.run(FISH, "-c", "string upper fish", env = CLEAN)
expect.ok(r_string)
expect.contains(r_string.stdout, "FISH")

# Tier 3 (c): the `$version` shell variable is part of fish's documented
# contract and reports the running version — assert its shape, not the exact
# value. This also proves the data dir loaded (fish needs its share dir to
# start a -c shell).
r_var = ocx.run(FISH, "-c", "echo $version", env = CLEAN)
expect.ok(r_var)
expect.matches(r_var.stdout, r"\d+\.\d+\.\d+")
