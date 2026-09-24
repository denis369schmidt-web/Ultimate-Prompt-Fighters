#pragma once

#include "CoreMinimal.h"
#include "AIController.h"
#include "PFUAIController.generated.h"

class APFUFighterCharacter;

UCLASS()
class PROMPTFIGHTERULTIMATE_API APFUAIController : public AAIController
{
    GENERATED_BODY()

public:
    APFUAIController();
    virtual void Tick(float DeltaSeconds) override;
    void SetTarget(APFUFighterCharacter* InTarget) { Target = InTarget; }

private:
    UPROPERTY() TObjectPtr<APFUFighterCharacter> Target;
    float DecisionCooldown = 0.0f;
};

