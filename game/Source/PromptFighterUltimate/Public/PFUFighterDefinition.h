#pragma once

#include "CoreMinimal.h"
#include "Engine/DataAsset.h"
#include "PFUTypes.h"
#include "PFUFighterDefinition.generated.h"

class USkeletalMesh;
class UAnimInstance;

UCLASS(BlueprintType)
class PROMPTFIGHTERULTIMATE_API UPFUFighterDefinition : public UPrimaryDataAsset
{
    GENERATED_BODY()

public:
    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="PFU")
    FPFUFighterProfile Profile;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="PFU|Visual")
    TSoftObjectPtr<USkeletalMesh> SkeletalMesh;

    UPROPERTY(EditAnywhere, BlueprintReadOnly, Category="PFU|Visual")
    TSoftClassPtr<UAnimInstance> AnimationClass;
};
