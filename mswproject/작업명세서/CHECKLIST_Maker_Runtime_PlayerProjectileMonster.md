# CHECKLIST_Maker_Runtime_PlayerProjectileMonster

- Date: `2026-02-25`
- Scope: `Player`, `Projectile(8)`, `Monster(normal_s)` combat-core alignment
- Status: `Static validation completed / Maker runtime pending`

## 1) Static Validation (Completed)

| ID | Check Item | Result | Evidence |
|---|---|---|---|
| S1 | `DefaultPlayer.model` has `HPSystem.IsMonster=false`, `IsDead=false`, `IsInvincible=false` | PASS | `Global/DefaultPlayer.model` values |
| S2 | `normal_s.model` includes `HPSystem`, `Trigger`, `MonsterChase` components | PASS | `RootDesk/MyDesk/ProjectGR/model/monstermodel/normal_s.model` components |
| S3 | `normal_s.model` has `HPSystem.IsMonster=true`, `IsDead=false` | PASS | same file values |
| S4 | `normal_s.model` has `Trigger.IsPassive=false`, `MonsterChase.Enable=true` | PASS | same file values |
| S5 | All projectile 8 models include `ProjectileComponent + TriggerComponent` | PASS | `RootDesk/MyDesk/ProjectGR/model/projectile/*.model` |
| S6 | All projectile 8 models have `Projectile.Enable=true`, `Trigger.Enable=true`, `Trigger.IsPassive=false` | PASS | same files values |
| S7 | Monster i-frame split code exists (`players only`) | PASS | `Components/Combat/HPSystemComponent.mlua` |
| S8 | Projectile monster-only target filter code exists | PASS | `Components/Combat/ProjectileComponent.mlua` |
| S9 | Spawned monster gets `HPSystem.IsMonster=true` | PASS | `Components/Combat/MonsterSpawnComponent.mlua` |

## 2) Maker Runtime Validation (Run In Maker)

| ID | Test Item | Steps | Expected | Result |
|---|---|---|---|---|
| B1 | Player hit invincible window | 1) Let monster contact player 2) Keep contact during i-frame | Additional HP loss is blocked during `HitInvincibleDuration` | TODO |
| B2 | Projectile damages monster | 1) Fire single projectile 2) Hit `normal_s` | Monster HP decreases and hit is applied | TODO |
| B3 | Monster chase/contact damage | 1) Place `normal_s` in map 2) Approach player | Monster chases player and contact damage applies | TODO |
| B4 | Projectile 8 trigger behavior | Fire all 8 projectile models and observe hit events | Trigger/hit behavior works for all 8 | TODO |
| B5 | Static vs spawned monster parity | Compare map-placed `normal_s` vs spawned monsters | Same combat behavior in both paths | TODO |

## 3) Notes

- CollisionGroup matrix was intentionally not changed in this batch.
- If runtime test fails, first re-check model values above and then table bindings in:
  - `WeaponData.csv`
  - `ProjectileData.csv`
  - `SummonData.csv`
