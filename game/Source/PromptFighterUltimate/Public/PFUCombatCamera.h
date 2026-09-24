#pragma once

#include "CoreMinimal.h"
#include "Camera/CameraActor.h"
#include "PFUCombatCamera.generated.h"

class APFUFighterCharacter;

UCLASS()
class PROMPTFIGHTERULTIMATE_API APFUCombatCamera : public ACameraActor
{
    GENERATED_BODY()

public:
    APFUCombatCamera();
    virtual void Tick(float DeltaSeconds) override;
    void SetFighters(APFUFighterCharacter* InA, APFUFighterCharacter* InB);

private:
    UPROPERTY() TObjectPtr<APFUFighterCharacter> FighterA;
    UPROPERTY() TObjectPtr<APFUFighterCharacter> FighterB;
};

